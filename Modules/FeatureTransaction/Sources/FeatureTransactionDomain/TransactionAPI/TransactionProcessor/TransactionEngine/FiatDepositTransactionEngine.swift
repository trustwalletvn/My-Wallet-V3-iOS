// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class FiatDepositTransactionEngine: TransactionEngine {

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        .empty()
    }

    let fiatCurrencyService: FiatCurrencyServiceAPI
    let priceService: PriceServiceAPI
    let requireSecondPassword: Bool = false
    let canTransactFiat: Bool = true
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceBankAccount: LinkedBankAccount! {
        sourceAccount as? LinkedBankAccount
    }

    var target: FiatAccount { transactionTarget as! FiatAccount }
    var targetAsset: FiatCurrency { target.fiatCurrency }
    var sourceAsset: FiatCurrency { sourceBankAccount.fiatCurrency }

    // MARK: - Private Properties

    private let linkedBanksFactory: LinkedBanksFactoryAPI
    private let bankTransferRepository: BankTransferRepositoryAPI

    // MARK: - Init

    init(
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        linkedBanksFactory: LinkedBanksFactoryAPI = resolve(),
        bankTransferRepository: BankTransferRepositoryAPI = resolve()
    ) {
        self.linkedBanksFactory = linkedBanksFactory
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.bankTransferRepository = bankTransferRepository
    }

    // MARK: - TransactionEngine

    func assertInputsValid() {
        precondition(sourceAccount is LinkedBankAccount)
        precondition(transactionTarget is FiatAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single
            .just(target.fiatCurrency)
            .flatMap(weak: self) { (self, fiatCurrecy) -> Single<PaymentLimits> in
                self.fetchBankTransferLimits(fiatCurrency: fiatCurrecy)
            }
            .map(weak: self) { (self, paymentLimits) -> PendingTransaction in
                PendingTransaction(
                    amount: .zero(currency: self.sourceAsset),
                    available: paymentLimits.max.transactional.moneyValue,
                    feeAmount: .zero(currency: self.sourceAsset),
                    feeForFullAvailable: .zero(currency: self.sourceAsset),
                    feeSelection: .init(selectedLevel: .none, availableLevels: []),
                    selectedFiatCurrency: paymentLimits.min.currencyType,
                    minimumLimit: paymentLimits.min.moneyValue,
                    maximumLimit: paymentLimits.max.transactional.moneyValue,
                    maximumDailyLimit: paymentLimits.max.daily.moneyValue,
                    maximumAnnualLimit: paymentLimits.max.annual.moneyValue
                )
            }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction
            .update(
                confirmations: [
                    .source(.init(value: sourceAccount.label)),
                    .destination(.init(value: target.label)),
                    .transactionFee(.init(fee: pendingTransaction.feeAmount)),
                    .arrivalDate(.default),
                    .total(.init(total: pendingTransaction.amount))
                ]
            )
        )
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        .just(pendingTransaction.update(amount: amount))
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        if pendingTransaction.validationState == .uninitialized, pendingTransaction.amount.isZero {
            return .just(pendingTransaction)
        } else {
            return validateAmountCompletable(pendingTransaction: pendingTransaction)
                .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
        }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
            .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        sourceAccount
            .receiveAddress
            .map(\.address)
            .flatMap(weak: self) { (self, identifier) -> Single<String> in
                // TODO: Handle OB
                self.bankTransferRepository
                    .startBankTransfer(
                        id: identifier,
                        amount: pendingTransaction.amount
                    )
                    .map(\.paymentId)
                    .asObservable()
                    .asSingle()
            }
            .map { TransactionResult.hashed(txHash: $0, amount: pendingTransaction.amount) }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        // TODO: Handle OB
        .just(event: .completed)
    }

    func doUpdateFeeLevel(pendingTransaction: PendingTransaction, level: FeeLevel, customFeeAmount: MoneyValue) -> Single<PendingTransaction> {
        precondition(pendingTransaction.feeSelection.availableLevels.contains(level))
        return .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func fetchBankTransferLimits(fiatCurrency: FiatCurrency) -> Single<PaymentLimits> {
        linkedBanksFactory
            .bankTransferLimits(for: fiatCurrency)
    }

    private func validateAmountCompletable(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            guard let maxLimit = pendingTransaction.maximumLimit,
                  let minLimit = pendingTransaction.minimumLimit
            else {
                throw TransactionValidationFailure(state: .unknownError)
            }
            guard !pendingTransaction.amount.isZero else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
            guard try pendingTransaction.amount >= minLimit else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
            guard try pendingTransaction.amount <= maxLimit else {
                throw TransactionValidationFailure(state: .overMaximumLimit)
            }
        }
    }
}
