// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

final class EthereumOnChainTransactionEngine: OnChainTransactionEngine {

    typealias AskForRefreshConfirmations =  (Bool) -> Completable

    // MARK: - OnChainTransactionEngine

    var askForRefreshConfirmation: (AskForRefreshConfirmations)!

    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    let requireSecondPassword: Bool
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

    // MARK: - Private Properties

    private let feeCache: CachedValue<EthereumTransactionFee>
    private let feeService: AnyCryptoFeeService<EthereumTransactionFee>
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let ethereumWalletService: EthereumWalletServiceAPI
    private let priceService: PriceServiceAPI
    private let bridge: EthereumWalletBridgeAPI

    private var receiveAddress: Single<ReceiveAddress> {
        switch transactionTarget {
        case is ReceiveAddress:
            return .just(transactionTarget as! ReceiveAddress)
        case is CryptoAccount:
            return (transactionTarget as! CryptoAccount).receiveAddress
        default:
            fatalError("Impossible State for Ethereum On Chain Engine: transactionTarget is \(type(of: transactionTarget))")
        }
    }

    // MARK: - Init

    init(requireSecondPassword: Bool,
         priceService: PriceServiceAPI = resolve(),
         fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
         feeService: AnyCryptoFeeService<EthereumTransactionFee> = resolve(),
         ethereumWalletService: EthereumWalletServiceAPI = resolve(),
         ethereumWalletBridgeAPI: EthereumWalletBridgeAPI = resolve()) {
        self.fiatCurrencyService = fiatCurrencyService
        self.feeService = feeService
        self.ethereumWalletService = ethereumWalletService
        self.requireSecondPassword = requireSecondPassword
        self.priceService = priceService
        self.bridge = ethereumWalletBridgeAPI
        feeCache = CachedValue(configuration: .init(refreshType: .periodic(seconds: 20)))
        feeCache.setFetch(weak: self) { (self) -> Single<EthereumTransactionFee> in
            self.feeService.fees
        }
    }

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoCurrency == .ethereum)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .map { fiatCurrency -> PendingTransaction in
                .init(
                    amount: MoneyValue.zero(currency: .ethereum),
                    available: MoneyValue.zero(currency: .ethereum),
                    feeAmount: MoneyValue.zero(currency: .ethereum),
                    feeForFullAvailable: MoneyValue.zero(currency: .ethereum),
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular, .priority],
                        asset: .crypto(.ethereum)
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
            .map { (fiatAmountAndFees, feeSelectionOption) ->
                (amountInFiat: MoneyValue, feesInFiat: MoneyValue, feeSelectionOption: TransactionConfirmation.Model.FeeSelection) in
                let (amountInFiat, feesInFiat) = fiatAmountAndFees
                return (amountInFiat.moneyValue, feesInFiat.moneyValue, feeSelectionOption)
            }
            .map(weak: self) { (self, payload) -> [TransactionConfirmation] in
                [
                    .sendDestinationValue(.init(value: pendingTransaction.amount)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.transactionTarget.label)),
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
        guard let crypto = amount.cryptoValue else {
            preconditionFailure("Not a `CryptoValue`")
        }
        guard crypto.currencyType == .ethereum else {
            preconditionFailure("Not an ethereum value")
        }
        return Single.zip(
            sourceAccount.actionableBalance,
            absoluteFee(with: pendingTransaction.feeLevel)
        )
        .map { (values) -> PendingTransaction in
            let (actionableBalance, fee) = values
            let available = try actionableBalance - fee.moneyValue
            let zero: MoneyValue = .zero(currency: actionableBalance.currency)
            let max = try MoneyValue.max(available, zero)
            return pendingTransaction.update(
                amount: amount,
                available: max,
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
        sourceAccount.actionableBalance
            .flatMap(weak: self) { (self, actionableBalance) -> Single<PendingTransaction> in
                self.validateAmounts(pendingTransaction: pendingTransaction)
                    .andThen(self.validateSufficientFunds(pendingTransaction: pendingTransaction, actionableBalance: actionableBalance))
                    .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        sourceAccount.actionableBalance
            .flatMap(weak: self) { (self, actionableBalance) -> Single<PendingTransaction> in
                self.validateAmounts(pendingTransaction: pendingTransaction)
                    .andThen(self.validateSufficientFunds(pendingTransaction: pendingTransaction, actionableBalance: actionableBalance))
                    .andThen(self.validateNoPendingTransaction())
                    .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
            }
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        guard let crypto = pendingTransaction.amount.cryptoValue else {
            preconditionFailure("Not a `CryptoValue`")
        }
        guard let ethereumValue = try? EthereumValue(crypto: crypto) else {
            preconditionFailure("Not an ethereum value")
        }

        return receiveAddress
            .map(\.address)
            .map { try EthereumAccountAddress(string: $0) }
            .map { $0.ethereumAddress }
            .flatMap(weak: self) { (self, address) -> Single<EthereumTransactionCandidate> in
                self.ethereumWalletService
                    .buildTransaction(with: ethereumValue, to: address, feeLevel: pendingTransaction.feeLevel)
            }
            .flatMap(weak: self) { (self, candidate) -> Single<EthereumTransactionPublished> in
                self.ethereumWalletService
                    .send(transaction: candidate, secondPassword: secondPassword)
            }
            .map { TransactionResult.hashed(txHash: $0.transactionHash, amount: pendingTransaction.amount) }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        unimplemented()
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .never()
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        unimplemented()
    }

    // MARK: - Private Functions

    private func validateNoPendingTransaction() -> Completable {
        bridge
            .isWaitingOnTransaction
            .map { (isWaitingOnTransaction) -> Void in
                guard isWaitingOnTransaction == false else {
                    throw TransactionValidationFailure(state: .transactionInFlight)
                }
            }
            .asCompletable()
    }

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            if try pendingTransaction.amount <= .init(cryptoValue: .etherZero) {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction, actionableBalance: MoneyValue) -> Completable {
        absoluteFee(with: pendingTransaction.feeLevel)
            .map { fee -> Void in
                if try (try fee.moneyValue + pendingTransaction.amount) > actionableBalance {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
            }
            .asCompletable()
    }

    private func makeFeeSelectionOption(pendingTransaction: PendingTransaction) -> Single<TransactionConfirmation.Model.FeeSelection> {
        Single
            .just(pendingTransaction)
            .map(weak: self) { (self, pendingTransaction) -> FeeState in
                try self.getFeeState(pendingTransaction: pendingTransaction)
            }
            .map { (feeState) -> TransactionConfirmation.Model.FeeSelection in
                TransactionConfirmation.Model.FeeSelection(
                    feeState: feeState,
                    selectedLevel: pendingTransaction.feeLevel,
                    fee: pendingTransaction.feeAmount
                )
            }
    }

    private func absoluteFee(with feeLevel: FeeLevel) -> Single<CryptoValue> {
        feeCache
            .valueSingle
            .map { (fees: EthereumTransactionFee) -> CryptoValue in
                let level: EthereumTransactionFee.FeeLevel
                switch feeLevel {
                case .none:
                    fatalError("On chain ETH transactions should never have a 0 fee")
                case .custom:
                    fatalError("Not supported")
                case .priority:
                    level = .priority
                case .regular:
                    level = .regular
                }
                return fees.absoluteFee(with: level, isContract: false)
            }
    }

    private func fiatAmountAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .etherZero),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .etherZero)
        )
        .map({ (quote: ($0.0.quote.fiatValue ?? .zero(currency: .USD)), amount: $0.1, fees: $0.2) })
        .map { (quote: (FiatValue), amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
            let fiatAmount = amount.convertToFiatValue(exchangeRate: quote)
            let fiatFees = fees.convertToFiatValue(exchangeRate: quote)
            return (fiatAmount, fiatFees)
        }
        .map { (amount: $0.0, fees: $0.1) }
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(for: self.sourceAsset, in: fiatCurrency)
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAsset), quote: $0) }
            }
    }
}
