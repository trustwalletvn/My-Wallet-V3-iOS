// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

public protocol InterestTransactionEngine: TransactionEngine {

    // MARK: - Services

    var fiatCurrencyService: FiatCurrencyServiceAPI { get }
    var priceService: PriceServiceAPI { get }

    // MARK: - Properties

    var minimumDepositLimits: Single<FiatValue> { get }
}

extension InterestTransactionEngine {

    // MARK: - Public Functions

    public func checkIfAmountIsBelowMinimumLimit(_ pendingTransaction: PendingTransaction) -> Completable {
        Completable.fromCallable {
            guard let minimum = pendingTransaction.minimumLimit else {
                throw TransactionValidationFailure(state: .uninitialized)
            }
            guard try pendingTransaction.amount > minimum else {
                throw TransactionValidationFailure(state: .belowMinimumLimit)
            }
        }
    }

    public func checkIfAvailableBalanceIsSufficient(
        _ pendingTransaction: PendingTransaction,
        balance: MoneyValue
    ) -> Completable {
        Completable.fromCallable {
            guard try pendingTransaction.amount <= balance else {
                throw TransactionValidationFailure(state: .insufficientFunds)
            }
        }
    }

    public func fiatAmountAndFees(
        from pendingTransaction: PendingTransaction
    ) -> Single<(amount: FiatValue, fees: FiatValue)> {
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

    // MARK: - Internal

    var sourceExchangeRatePair: Single<MoneyValuePair> {
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

extension InterestTransactionEngine where Self: TransactionEngine {

    public var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        sourceExchangeRatePair
            .map { pair -> TransactionMoneyValuePairs in
                TransactionMoneyValuePairs(
                    source: pair,
                    destination: pair
                )
            }
            .asObservable()
    }
}
