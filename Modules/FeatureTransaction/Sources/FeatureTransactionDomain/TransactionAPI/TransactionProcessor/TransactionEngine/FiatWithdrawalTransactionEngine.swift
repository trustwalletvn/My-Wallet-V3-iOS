// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class FiatWithdrawalTransactionEngine: TransactionEngine {

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

    var sourceTradingAccount: FiatAccount! {
        sourceAccount as? FiatAccount
    }

    var target: LinkedBankAccount { transactionTarget as! LinkedBankAccount }
    var targetAsset: FiatCurrency { target.fiatCurrency }
    var sourceAsset: FiatCurrency { sourceTradingAccount.fiatCurrency }

    // MARK: - Private Properties

    private let fiatWithdrawRepository: FiatWithdrawRepositoryAPI

    // MARK: - Init

    init(
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        fiatWithdrawRepository: FiatWithdrawRepositoryAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.fiatWithdrawRepository = fiatWithdrawRepository
    }

    // MARK: - TransactionEngine

    func assertInputsValid() {
        precondition(sourceAccount is FiatAccount)
        precondition(transactionTarget is LinkedBankAccount)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        Single.zip(
            sourceAccount.actionableBalance,
            sourceAccount.balance,
            target.withdrawFeeAndMinLimit,
            fiatCurrencyService
                .fiatCurrency
        )
        .map(weak: self) { (self, values) -> PendingTransaction in
            let (actionableBalance, _, feeAndLimit, fiatCurrency) = values
            let zero: MoneyValue = .zero(currency: self.sourceAsset)
            return PendingTransaction(
                amount: zero,
                // TODO: Total balance?
                available: actionableBalance,
                feeAmount: feeAndLimit.fee.moneyValue,
                feeForFullAvailable: zero,
                feeSelection: .init(
                    selectedLevel: .none,
                    availableLevels: []
                ),
                selectedFiatCurrency: fiatCurrency,
                minimumLimit: feeAndLimit.minLimit.moneyValue,
                maximumLimit: actionableBalance
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
        target
            .receiveAddress
            .map(\.address)
            .flatMapCompletable(weak: self) { (self, address) -> Completable in
                self.fiatWithdrawRepository
                    .createWithdrawOrder(id: address, amount: pendingTransaction.amount)
                    .asObservable()
                    .ignoreElements()
            }
            .flatMapSingle {
                .just(TransactionResult.unHashed(amount: pendingTransaction.amount))
            }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        .empty()
    }

    func doUpdateFeeLevel(pendingTransaction: PendingTransaction, level: FeeLevel, customFeeAmount: MoneyValue) -> Single<PendingTransaction> {
        precondition(pendingTransaction.feeSelection.availableLevels.contains(level))
        return .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func validateAmountCompletable(pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            guard let maxLimit = pendingTransaction.maximumLimit,
                  let minLimit = pendingTransaction.minimumLimit
            else {
                throw TransactionValidationFailure(state: .unknownError)
            }
            guard try pendingTransaction.amount >= minLimit else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
            guard try pendingTransaction.amount <= maxLimit else {
                throw TransactionValidationFailure(state: .overMaximumLimit)
            }
            guard try pendingTransaction.available >= pendingTransaction.amount else {
                throw TransactionValidationFailure(state: .insufficientFunds)
            }
        }
    }
}
