// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift
import ToolKit

final class TradingToOnChainTransactionEngine: TransactionEngine {

    /// This might need to be `1:1` as there isn't a transaction pair.
    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        .empty()
    }

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

    let fiatCurrencyService: FiatCurrencyServiceAPI
    let priceService: PriceServiceAPI
    let requireSecondPassword: Bool = false
    let isNoteSupported: Bool
    var askForRefreshConfirmation: ((Bool) -> Completable)!
    var sourceAccount: BlockchainAccount!
    var transactionTarget: TransactionTarget!

    var sourceTradingAccount: CryptoTradingAccount! {
        sourceAccount as? CryptoTradingAccount
    }

    var target: CryptoReceiveAddress {
        transactionTarget as! CryptoReceiveAddress
    }

    var targetAsset: CryptoCurrency { target.asset }

    // MARK: - Private Properties

    private let feeCache: CachedValue<CustodialTransferFee>
    private let transferRepository: CustodialTransferRepositoryAPI

    // MARK: - Init

    init(
        isNoteSupported: Bool = false,
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        priceService: PriceServiceAPI = resolve(),
        transferRepository: CustodialTransferRepositoryAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.isNoteSupported = isNoteSupported
        self.transferRepository = transferRepository
        feeCache = CachedValue(configuration: .periodic(20))
        feeCache.setFetch(weak: self) { (self) -> Single<CustodialTransferFee> in
            self.transferRepository.fees()
                .asObservable()
                .asSingle()
        }
    }

    func assertInputsValid() {
        precondition(transactionTarget is CryptoReceiveAddress)
        precondition(sourceAsset == targetAsset)
    }

    func initializeTransaction() -> Single<PendingTransaction> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<PendingTransaction> in
                .just(
                    .init(
                        amount: .zero(currency: self.sourceAsset),
                        available: .zero(currency: self.sourceAsset),
                        feeAmount: .zero(currency: self.sourceAsset),
                        feeForFullAvailable: .zero(currency: self.sourceAsset),
                        feeSelection: .empty(asset: self.sourceAsset),
                        selectedFiatCurrency: fiatCurrency,
                        minimumLimit: .zero(currency: self.sourceAsset)
                    )
                )
            }
    }

    func update(amount: MoneyValue, pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        guard sourceTradingAccount != nil else {
            return .just(pendingTransaction)
        }
        return
            Single
                .zip(feeCache.valueSingle, sourceTradingAccount.withdrawableBalance)
                .map { fees, withdrawableBalance -> PendingTransaction in
                    let fee = fees[fee: amount.currencyType]
                    let available = try withdrawableBalance - fee
                    var pendingTransaction = pendingTransaction.update(
                        amount: amount,
                        available: available.isNegative ? .zero(currency: available.currency) : available,
                        fee: fee,
                        feeForFullAvailable: fee
                    )
                    pendingTransaction.minimumLimit = fees[minimumAmount: amount.currencyType]
                    return pendingTransaction
                }
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        fiatAmountAndFees(from: pendingTransaction)
            .map(weak: self) { (self, fiatAmountAndFees) -> [TransactionConfirmation] in
                var confirmations: [TransactionConfirmation] = [
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .networkFee(.init(
                        fee: fiatAmountAndFees.fees.moneyValue,
                        feeType: .withdrawalFee,
                        asset: self.sourceAsset
                    )),
                    .total(.init(total: fiatAmountAndFees.amount.moneyValue))
                ]
                if self.isNoteSupported {
                    confirmations.append(.destination(.init(value: "")))
                }
                return confirmations
            }
            .map { confirmations -> PendingTransaction in
                pendingTransaction.update(confirmations: confirmations)
            }
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmounts(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func execute(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<TransactionResult> {
        transferRepository
            .transfer(
                moneyValue: pendingTransaction.amount,
                destination: target.address,
                memo: target.memo
            )
            .asObservable()
            .asSingle()
            .map { identifier -> TransactionResult in
                TransactionResult.hashed(txHash: identifier, amount: pendingTransaction.amount)
            }
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        target.onTxCompleted(transactionResult)
    }

    func doUpdateFeeLevel(
        pendingTransaction: PendingTransaction,
        level: FeeLevel,
        customFeeAmount: MoneyValue
    ) -> Single<PendingTransaction> {
        precondition(pendingTransaction.availableFeeLevels.contains(level))
        /// `TradingToOnChainTransactionEngine` only supports a
        /// `FeeLevel` of `.none`
        return .just(pendingTransaction)
    }

    // MARK: - Private Functions

    private func validateAmounts(pendingTransaction: PendingTransaction) -> Completable {
        Completable.deferred { () -> Completable in
            guard pendingTransaction.amount.isPositive else {
                throw TransactionValidationFailure(state: .invalidAmount)
            }
            guard try pendingTransaction.amount <= pendingTransaction.available else {
                throw TransactionValidationFailure(state: .insufficientFunds)
            }
            guard let minimumLimit = pendingTransaction.minimumLimit else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
            guard try pendingTransaction.amount >= minimumLimit else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
            return .just(event: .completed)
        }
    }

    private func fiatAmountAndFees(from pendingTransaction: PendingTransaction) -> Single<(amount: FiatValue, fees: FiatValue)> {
        Single.zip(
            sourceExchangeRatePair,
            .just(pendingTransaction.amount.cryptoValue ?? .zero(currency: sourceCryptoCurrency)),
            .just(pendingTransaction.feeAmount.cryptoValue ?? .zero(currency: sourceCryptoCurrency))
        )
        .map { (quote: $0.0.quote.fiatValue ?? .zero(currency: .USD), amount: $0.1, fees: $0.2) }
        .map { (quote: FiatValue, amount: CryptoValue, fees: CryptoValue) -> (FiatValue, FiatValue) in
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
                    .price(of: self.sourceAsset, in: fiatCurrency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.sourceAsset), quote: $0) }
            }
    }
}
