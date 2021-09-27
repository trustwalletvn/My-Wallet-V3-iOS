// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift
import stellarsdk
import ToolKit

final class StellarOnChainTransactionEngine: OnChainTransactionEngine {

    typealias AskForRefreshConfirmation = (Bool) -> Completable

    // MARK: - Properties

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

    var askForRefreshConfirmation: (AskForRefreshConfirmation)!
    var requireSecondPassword: Bool
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!
    var fiatCurrencyService: FiatCurrencyServiceAPI
    var priceService: PriceServiceAPI
    var transactionDispatcher: StellarTransactionDispatcher
    var feeService: AnyCryptoFeeService<StellarTransactionFee>

    // MARK: - Private properties

    private var receiveAddress: ReceiveAddress {
        transactionTarget as! ReceiveAddress
    }

    private var userFiatCurrency: Single<FiatCurrency> {
        fiatCurrencyService.fiatCurrency
    }

    private var sourceExchangeRatePair: Single<MoneyValuePair> {
        userFiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(of: self.sourceAsset, in: fiatCurrency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAsset), quote: $0) }
            }
    }

    private var isMemoRequired: Single<Bool> {
        transactionDispatcher.isExchangeAddresses(address: receiveAddress.address)
    }

    private var absoluteFee: Single<CryptoValue> {
        feeService.fees.map(\.regular)
    }

    // MARK: - Init

    init(
        requireSecondPassword: Bool,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        feeService: AnyCryptoFeeService<StellarTransactionFee> = resolve(),
        transactionDispatcher: StellarTransactionDispatcher = resolve()
    ) {
        self.requireSecondPassword = requireSecondPassword
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.transactionDispatcher = transactionDispatcher
        self.feeService = feeService
    }

    // MARK: - Internal Methods

    func assertInputsValid() {
        defaultAssertInputsValid()
        precondition(sourceCryptoCurrency == .coin(.stellar))
    }

    func restart(transactionTarget: TransactionTarget, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        Single.zip(defaultRestart(transactionTarget: transactionTarget, pendingTransaction: pendingTransaction), isMemoRequired)
            .map { [receiveAddress] pendingTransaction, isMemoRequired -> PendingTransaction in
                guard let stellarReceive = receiveAddress as? StellarReceiveAddress else {
                    return pendingTransaction
                }
                var pendingTransaction = pendingTransaction
                let memoModel = TransactionConfirmation.Model.Memo(
                    textMemo: stellarReceive.memo,
                    required: isMemoRequired
                )
                pendingTransaction.setMemo(memo: memoModel)
                return pendingTransaction
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        sourceExchangeRatePair
            .map(weak: self) { (self, exchangeRate) -> [TransactionConfirmation] in
                let from = TransactionConfirmation.Model.Source(value: self.sourceAccount.label)
                let to = TransactionConfirmation.Model.Destination(value: self.receiveAddress.label)
                let feesFiat = try pendingTransaction.feeAmount.convert(using: exchangeRate.quote)
                let fee = self.makeFeeSelectionOption(
                    pendingTransaction: pendingTransaction,
                    feesFiat: feesFiat
                )
                let feedTotal = TransactionConfirmation.Model.FeedTotal(
                    amount: pendingTransaction.amount,
                    amountInFiat: try pendingTransaction.amount.convert(using: exchangeRate.quote),
                    fee: pendingTransaction.feeAmount,
                    feeInFiat: feesFiat
                )
                let sendDestination = TransactionConfirmation.Model.SendDestinationValue(
                    value: pendingTransaction.amount
                )
                return [
                    .sendDestinationValue(sendDestination),
                    .source(from),
                    .destination(to),
                    .feeSelection(fee),
                    .feedTotal(feedTotal),
                    .memo(pendingTransaction.memo)
                ]
            }
            .map { confirmations in
                pendingTransaction.update(confirmations: confirmations)
            }
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(userFiatCurrency, isMemoRequired)
            .map { [receiveAddress] fiatCurrency, isMemoRequired -> PendingTransaction in
                var memo: String?
                if let stellarReceive = receiveAddress as? StellarReceiveAddress {
                    memo = stellarReceive.memo
                }
                let memoModel = TransactionConfirmation.Model.Memo(
                    textMemo: memo,
                    required: isMemoRequired
                )
                let zeroStellar = CryptoValue.zero(currency: .coin(.stellar)).moneyValue
                var transaction = PendingTransaction(
                    amount: zeroStellar,
                    available: zeroStellar,
                    feeAmount: zeroStellar,
                    feeForFullAvailable: zeroStellar,
                    feeSelection: .init(
                        selectedLevel: .regular,
                        availableLevels: [.regular],
                        asset: .crypto(.coin(.stellar))
                    ),
                    selectedFiatCurrency: fiatCurrency,
                    minimumLimit: nil,
                    maximumLimit: nil
                )
                transaction.setMemo(memo: memoModel)
                return transaction
            }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        precondition(amount.currency == .crypto(.coin(.stellar)))
        let actionableBalance = sourceAccount.actionableBalance.map(\.cryptoValue)
        return Single
            .zip(actionableBalance, absoluteFee)
            .map { actionableBalance, fees -> PendingTransaction in
                guard let actionableBalance = actionableBalance else {
                    throw PlatformKitError.illegalStateException(message: "actionableBalance not CryptoValue")
                }
                let zeroStellar = CryptoValue.zero(currency: .coin(.stellar))
                let total = try actionableBalance - fees
                let available = (try total < zeroStellar) ? zeroStellar : total
                var pendingTransaction = pendingTransaction
                pendingTransaction.amount = amount
                pendingTransaction.feeForFullAvailable = fees.moneyValue
                pendingTransaction.feeAmount = fees.moneyValue
                pendingTransaction.available = available.moneyValue
                return pendingTransaction
            }
    }

    func doOptionUpdateRequest(pendingTransaction: PendingTransaction, newConfirmation: TransactionConfirmation) -> Single<PendingTransaction> {
        defaultDoOptionUpdateRequest(pendingTransaction: pendingTransaction, newConfirmation: newConfirmation)
            .map { pendingTransaction -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                switch newConfirmation {
                case .memo(let memo):
                    pendingTransaction.setMemo(memo: memo)
                default:
                    break
                }
                return pendingTransaction
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateTargetAddress()
            .andThen(validateAmounts(pendingTransaction: pendingTransaction))
            .andThen(validateSufficientFunds(pendingTransaction: pendingTransaction))
            .andThen(validateOptions(pendingTransaction: pendingTransaction))
            .andThen(validateDryRun(pendingTransaction: pendingTransaction))
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, sendDetails) -> Single<SendConfirmationDetails> in
                self.transactionDispatcher.sendFunds(sendDetails: sendDetails, secondPassword: secondPassword)
            }
            .map { result in
                TransactionResult.hashed(txHash: result.transactionHash, amount: pendingTransaction.amount)
            }
    }

    // MARK: - Private methods

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            guard pendingTransaction.amount.isPositive else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
        }
    }

    private func validateSufficientFunds(pendingTransaction: PendingTransaction) -> Completable {
        Single.zip(sourceAccount.actionableBalance, absoluteFee)
            .map { balance, fee -> Void in
                if try (try fee.moneyValue + pendingTransaction.amount) > balance {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
            }
            .asCompletable()
    }

    private func createTransaction(pendingTransaction: PendingTransaction) -> Single<SendDetails> {
        let label = sourceAccount.label
        return sourceAccount.receiveAddress
            .map { [receiveAddress] sourceAccountReceiveAddress -> SendDetails in
                SendDetails(
                    fromAddress: sourceAccountReceiveAddress.address,
                    fromLabel: label,
                    toAddress: receiveAddress.address,
                    toLabel: "",
                    value: pendingTransaction.amount.cryptoValue!,
                    fee: pendingTransaction.feeAmount.cryptoValue!,
                    memo: pendingTransaction.memo.stellarMemo
                )
            }
    }

    private func isMemoValid(memo: TransactionConfirmation.Model.Memo?) -> Single<Bool> {
        func validText(memo: TransactionConfirmation.Model.Memo) -> Bool {
            guard case .text(let text) = memo.value else {
                return false
            }
            return 1...28 ~= text.count
        }
        func validIdentifier(memo: TransactionConfirmation.Model.Memo) -> Bool {
            guard case .identifier = memo.value else {
                return false
            }
            return true
        }
        return isMemoRequired
            .map { isMemoRequired -> Bool in
                guard isMemoRequired else {
                    return true
                }
                guard let memo = memo else {
                    return false
                }
                return validText(memo: memo) || validIdentifier(memo: memo)
            }
    }

    private func validateDryRun(pendingTransaction: PendingTransaction) -> Completable {
        createTransaction(pendingTransaction: pendingTransaction)
            .flatMapCompletable(weak: self) { (self, sendDetails) -> Completable in
                self.transactionDispatcher.dryRunTransaction(sendDetails: sendDetails)
            }
            .mapErrorToTransactionValidationFailure()
    }

    private func validateOptions(pendingTransaction: PendingTransaction) -> Completable {
        isMemoValid(memo: pendingTransaction.memo)
            .map { isMemoValid -> Void in
                guard isMemoValid else {
                    throw TransactionValidationFailure(state: .optionInvalid)
                }
            }
            .asCompletable()
    }

    private func validateTargetAddress() -> Completable {
        Completable.fromCallable(weak: self) { (self) in
            guard self.transactionDispatcher.isAddressValid(address: self.receiveAddress.address) else {
                throw TransactionValidationFailure(state: .invalidAddress)
            }
        }
    }

    private func makeFeeSelectionOption(
        pendingTransaction: PendingTransaction,
        feesFiat: MoneyValue
    ) -> TransactionConfirmation.Model.FeeSelection {
        TransactionConfirmation.Model.FeeSelection(
            feeState: .valid(absoluteFee: pendingTransaction.feeAmount),
            selectedLevel: pendingTransaction.feeLevel,
            fee: pendingTransaction.feeAmount
        )
    }
}

extension PendingTransaction {

    fileprivate var memo: TransactionConfirmation.Model.Memo {
        engineState[.xlmMemo] as! TransactionConfirmation.Model.Memo
    }

    fileprivate mutating func setMemo(memo: TransactionConfirmation.Model.Memo) {
        engineState[.xlmMemo] = memo
    }
}

extension TransactionConfirmation.Model.Memo {

    fileprivate var stellarMemo: StellarMemo? {
        switch value {
        case .none:
            return nil
        case .text(let text):
            return text.isEmpty ? nil : StellarMemo.text(text)
        case .identifier(let identifier):
            return StellarMemo.id(UInt64(identifier))
        }
    }
}

extension PrimitiveSequence where Trait == CompletableTrait, Element == Never {

    fileprivate func mapErrorToTransactionValidationFailure() -> Completable {
        catchError { error -> Completable in
            switch error {
            case SendFailureReason.unknown:
                throw TransactionValidationFailure(state: .unknownError)
            case SendFailureReason.belowMinimumSend:
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            case SendFailureReason.belowMinimumSendNewAccount:
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            case SendFailureReason.insufficientFunds:
                throw TransactionValidationFailure(state: .insufficientFunds)
            case SendFailureReason.badDestinationAccountID:
                throw TransactionValidationFailure(state: .invalidAddress)
            default:
                throw TransactionValidationFailure(state: .unknownError)
            }
        }
    }
}
