// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import EthereumKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import ToolKit

final class ERC20OnChainTransactionEngine: OnChainTransactionEngine {

    typealias AskForRefreshConfirmations = (Bool) -> Completable

    // MARK: - OnChainTransactionEngine

    var askForRefreshConfirmation: (AskForRefreshConfirmations)!

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    let requireSecondPassword: Bool

    // MARK: - Private Properties

    private let erc20Token: ERC20AssetModel
    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: EthereumKit.EthereumFeeServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let priceService: PriceServiceAPI
    private let ethereumAccountDetails: EthereumAccountDetailsServiceAPI
    private let erc20AccountService: ERC20AccountServiceAPI
    private let transactionBuildingService: EthereumTransactionBuildingServiceAPI
    private let ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI
    private let transactionsService: EthereumHistoricalTransactionServiceAPI
    private var target: ERC20ReceiveAddress {
        transactionTarget as! ERC20ReceiveAddress
    }

    // MARK: - Init

    init(
        erc20Token: ERC20AssetModel,
        requireSecondPassword: Bool,
        ethereumAccountDetails: EthereumAccountDetailsServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        feeService: EthereumKit.EthereumFeeServiceAPI = resolve(),
        transactionsService: EthereumHistoricalTransactionServiceAPI = resolve(),
        erc20AccountService: ERC20AccountServiceAPI = resolve(),
        transactionBuildingService: EthereumTransactionBuildingServiceAPI = resolve(),
        ethereumTransactionDispatcher: EthereumTransactionDispatcherAPI = resolve()
    ) {
        self.erc20Token = erc20Token
        self.ethereumAccountDetails = ethereumAccountDetails
        self.fiatCurrencyService = fiatCurrencyService
        self.feeService = feeService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.transactionsService = transactionsService
        self.erc20AccountService = erc20AccountService
        self.transactionBuildingService = transactionBuildingService
        self.ethereumTransactionDispatcher = ethereumTransactionDispatcher

        feeCache = .init(configuration: .onSubscription())
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService.fees(cryptoCurrency: self.sourceCryptoCurrency)
        }
    }

    // MARK: - OnChainTransactionEngine

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoCurrency.isERC20)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .map { [erc20Token] fiatCurrency -> PendingTransaction in
                .init(
                    amount: .zero(currency: erc20Token.cryptoCurrency),
                    available: .zero(currency: erc20Token.cryptoCurrency),
                    feeAmount: .zero(currency: .coin(.ethereum)),
                    feeForFullAvailable: .zero(currency: .coin(.ethereum)),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular, .priority],
                        asset: .crypto(.coin(.ethereum))
                    ),
                    selectedFiatCurrency: fiatCurrency
                )
            }
    }

    func start(
        sourceAccount: CryptoAccount,
        transactionTarget: TransactionTarget,
        askForRefreshConfirmation: @escaping AskForRefreshConfirmations
    ) {
        self.sourceAccount = sourceAccount
        self.transactionTarget = transactionTarget
        self.askForRefreshConfirmation = askForRefreshConfirmation
    }

    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultRestart(
            transactionTarget: transactionTarget,
            pendingTransaction: pendingTransaction
        )
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single
            .zip(
                fiatAmountAndFees(from: pendingTransaction),
                makeFeeSelectionOption(pendingTransaction: pendingTransaction)
            )
            .map { fiatAmountAndFees, feeSelectionOption ->
                (amountInFiat: MoneyValue, feesInFiat: MoneyValue, feeSelectionOption: TransactionConfirmation.Model.FeeSelection) in
                let (amountInFiat, feesInFiat) = fiatAmountAndFees
                return (amountInFiat.moneyValue, feesInFiat.moneyValue, feeSelectionOption)
            }
            .map(weak: self) { (self, payload) -> [TransactionConfirmation] in
                [
                    .sendDestinationValue(.init(value: pendingTransaction.amount)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .feeSelection(payload.feeSelectionOption),
                    .feedTotal(
                        .init(
                            amount: pendingTransaction.amount,
                            amountInFiat: payload.amountInFiat,
                            fee: pendingTransaction.feeAmount,
                            feeInFiat: payload.feesInFiat
                        )
                    )
                ]
            }
            .map { pendingTransaction.update(confirmations: $0) }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceAccount != nil else {
            return .just(pendingTransaction)
        }
        guard let crypto = amount.cryptoValue else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        guard crypto.currencyType == erc20Token.cryptoCurrency else {
            return .error(TransactionValidationFailure(state: .unknownError))
        }
        return Single.zip(
            sourceAccount.actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel, fetch: true)
        )
        .map { values -> PendingTransaction in
            let (actionableBalance, fee) = values
            return pendingTransaction.update(
                amount: amount,
                available: actionableBalance,
                fee: fee.moneyValue,
                feeForFullAvailable: fee.moneyValue
            )
        }
    }

    func doOptionUpdateRequest(pendingTransaction: PendingTransaction, newConfirmation: TransactionConfirmation) -> Single<PendingTransaction> {
        switch newConfirmation {
        case .feeSelection(let value) where value.selectedLevel != pendingTransaction.feeLevel:
            return updateFeeSelection(
                pendingTransaction: pendingTransaction,
                newFeeLevel: value.selectedLevel,
                customFeeAmount: nil
            )
        default:
            return defaultDoOptionUpdateRequest(
                pendingTransaction: pendingTransaction,
                newConfirmation: newConfirmation
            )
        }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAddresses()
            .andThen(validateAmounts(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientGas(pendingTransaction: pendingTransaction))
            .andThen(validateNoPendingTransaction())
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        Single.zip(feeCache.valueSingle, .just(target.address))
            .flatMap(weak: self) { (self, values) -> Single<EthereumTransactionCandidate> in
                let (fee, address) = values
                return self.transactionBuildingService.buildTransaction(
                    amount: pendingTransaction.amount,
                    to: EthereumAddress(address: address)!,
                    feeLevel: pendingTransaction.feeLevel,
                    fee: fee,
                    contractAddress: self.erc20Token.contractAddress
                )
            }
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.ethereumTransactionDispatcher.send(
                    transaction: candidate,
                    secondPassword: secondPassword
                )
            }
            .map(\.transactionHash)
            .map { transactionHash -> TransactionResult in
                .hashed(txHash: transactionHash, amount: pendingTransaction.amount)
            }
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func validateNoPendingTransaction() -> Completable {
        transactionsService
            .isWaitingOnTransaction
            .map { isWaitingOnTransaction -> Void in
                guard isWaitingOnTransaction == false else {
                    throw TransactionValidationFailure(state: .transactionInFlight)
                }
            }
            .asCompletable()
    }

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable { [erc20Token] in
            if try pendingTransaction.amount <= CryptoValue.zero(currency: erc20Token.cryptoCurrency).moneyValue {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        guard sourceAccount != nil else {
            fatalError("sourceAccount should never be nil when this is called")
        }
        return sourceAccount
            .actionableBalance
            .map { actionableBalance -> Void in
                guard try pendingTransaction.amount <= actionableBalance else {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
            }
            .asCompletable()
    }

    private func validateSufficientGas(pendingTransaction: PendingTransaction) -> Completable {
        Single
            .zip(
                ethereumAccountBalance,
                absoluteFee(with: pendingTransaction.feeLevel)
            )
            .map { balance, absoluteFee -> Void in
                guard try absoluteFee <= balance else {
                    throw TransactionValidationFailure(state: .insufficientGas)
                }
            }
            .asCompletable()
    }

    private func validateAddresses() -> Completable {
        erc20AccountService.isContract(address: target.address)
            .map { isContractAddress -> Bool in
                guard !isContractAddress else {
                    throw TransactionValidationFailure(state: .invalidAddress)
                }
                return isContractAddress
            }
            .asCompletable()
    }

    private func makeFeeSelectionOption(pendingTransaction: PendingTransaction) -> Single<TransactionConfirmation.Model.FeeSelection> {
        Single
            .just(pendingTransaction)
            .map(weak: self) { (self, pendingTransaction) -> FeeState in
                try self.getFeeState(pendingTransaction: pendingTransaction)
            }
            .map { feeState -> TransactionConfirmation.Model.FeeSelection in
                TransactionConfirmation.Model.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
    }

    private func fiatAmountAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            ethereumExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: erc20Token.cryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: erc20Token.cryptoCurrency))
        )
        .map { sourceExchange, ethereumExchange, amount, feeAmount -> (FiatValue, FiatValue) in
            let erc20Quote = sourceExchange.quote.fiatValue!
            let ethereumQuote = ethereumExchange.quote.fiatValue!
            let fiatAmount = amount.convertToFiatValue(exchangeRate: erc20Quote)
            let fiatFees = feeAmount.convertToFiatValue(exchangeRate: ethereumQuote)
            return (fiatAmount, fiatFees)
        }
    }

    private func absoluteFee(with feeLevel: FeeLevel, fetch: Bool = false) -> Single<CryptoValue> {
        feeCache.valueSingle
            .map { fees -> CryptoValue in
                fees.absoluteFee(with: feeLevel.ethereumFeeLevel, isContract: true)
            }
    }

    private var ethereumAccountBalance: Single<CryptoValue> {
        ethereumAccountDetails.accountDetails().map(\.balance)
    }

    /// Streams `MoneyValuePair` for the exchange rate of the source ERC20 Asset in the current fiat currency.
    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { [sourceAsset] (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(of: sourceAsset, in: fiatCurrency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: sourceAsset), quote: $0) }
            }
    }

    /// Streams `MoneyValuePair` for the exchange rate of Ethereum in the current fiat currency.
    private var ethereumExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(of: CurrencyType.crypto(.coin(.ethereum)), in: fiatCurrency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: .crypto(.coin(.ethereum))), quote: $0) }
            }
    }
}
