// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

protocol SwapTransactionEngine: TransactionEngine {

    var orderDirection: OrderDirection { get }
    var quotesEngine: SwapQuotesEngine { get }
    var orderCreationRepository: OrderCreationRepositoryAPI { get }
    var orderQuoteRepository: OrderQuoteRepositoryAPI { get }
    var tradeLimitsRepository: TransactionLimitsRepositoryAPI { get }
    var fiatCurrencyService: FiatCurrencyServiceAPI { get }
    var kycTiersService: KYCTiersServiceAPI { get }
    var priceService: PriceServiceAPI { get }
}

extension PendingTransaction {
    fileprivate var quoteSubscription: Disposable? {
        engineState[.quoteSubscription] as? Disposable
    }

    fileprivate var userTiers: KYC.UserTiers? {
        engineState[.userTiers] as? KYC.UserTiers
    }
}

extension SwapTransactionEngine {
    var target: CryptoAccount { transactionTarget as! CryptoAccount }
    var targetAsset: CryptoCurrency { target.asset }
    var sourceAsset: CryptoCurrency { sourceCryptoCurrency }

    var pair: OrderPair {
        OrderPair(
            sourceCurrencyType: sourceAsset.currency,
            destinationCurrencyType: target.asset.currency
        )
    }

    // MARK: - TransactionEngine

    func validateUpdateAmount(_ amount: MoneyValue) -> Single<MoneyValue> {
        switch (canTransactFiat, amount.isFiat) {
        case (true, true), (false, false):
            return .just(amount)
        default:
            // Error: canTransactFiat and amount.isFiat doesn't match.
            // This is an implementation error.
            preconditionFailure("Engine.canTransactFiat \(canTransactFiat) but amount.isFiat: \(amount.isFiat)")
        }
    }

    var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        Single.zip(sourceExchangeRatePair, destinationExchangeRatePair)
            .map { tuple -> TransactionMoneyValuePairs in
                let (source, destination) = tuple
                return TransactionMoneyValuePairs(
                    source: source,
                    destination: destination
                )
            }
            .asObservable()
    }

    var transactionExchangeRatePair: Observable<MoneyValuePair> {
        quotesEngine
            .getRate(
                direction: orderDirection,
                pair: .init(
                    sourceCurrencyType: sourceAsset,
                    destinationCurrencyType: target.currencyType
                )
            )
            .map(weak: self) { (self, pricedQuote) -> MoneyValue in
                MoneyValue(amount: pricedQuote.price, currency: self.target.currencyType)
            }
            .map(weak: self) { (self, rate) -> MoneyValuePair in
                try MoneyValuePair(base: .one(currency: self.sourceAsset), exchangeRate: rate)
            }
    }

    private func disposeQuotesFetching(pendingTransaction: PendingTransaction) {
        pendingTransaction.quoteSubscription?.dispose()
        quotesEngine.stop()
    }

    func clearConfirmations(pendingTransaction oldValue: PendingTransaction) -> PendingTransaction {
        var pendingTransaction = oldValue
        let quoteSubscription = pendingTransaction.quoteSubscription
        quoteSubscription?.dispose()
        pendingTransaction.engineState[.quoteSubscription] = nil
        return pendingTransaction.update(confirmations: [])
    }

    func stop(pendingTransaction: PendingTransaction) {
        disposeQuotesFetching(pendingTransaction: pendingTransaction)
    }

    func updateLimits(
        pendingTransaction: PendingTransaction,
        pricedQuote: PricedQuote,
        fiatCurrency: FiatCurrency
    ) -> Single<PendingTransaction> {
        Single
            .zip(
                kycTiersService.tiers,
                tradeLimitsRepository.fetchTransactionLimits(
                    currency: fiatCurrency.currency,
                    networkFee: targetAsset.currency,
                    product: .swap(orderDirection)
                )
                .asObservable()
                .asSingle()
            )
            .map { tiers, limits -> (tiers: KYC.UserTiers, min: FiatValue, max: FiatValue) in
                // TODO: Convert to `MoneyValuePair` so that
                // we can show crypto or fiat min/max values.
                (tiers, limits.minOrder, limits.maxOrder)
            }
            .flatMap(weak: self) { (self, values) -> Single<(KYC.UserTiers, MoneyValue, MoneyValue)> in
                let (tiers, min, max) = values
                return self.priceService
                    .price(
                        of: self.sourceAsset,
                        in: fiatCurrency
                    )
                    .asSingle()
                    .map(\.moneyValue)
                    .map { $0.fiatValue ?? .zero(currency: fiatCurrency) }
                    .map { quote -> (KYC.UserTiers, MoneyValue, MoneyValue) in
                        let minCrypto = min.convertToCryptoValue(exchangeRate: quote, cryptoCurrency: self.sourceCryptoCurrency)
                        let maxCrypto = max.convertToCryptoValue(exchangeRate: quote, cryptoCurrency: self.sourceCryptoCurrency)
                        return (tiers, .init(cryptoValue: minCrypto), .init(cryptoValue: maxCrypto))
                    }
            }
            .map { (tiers: KYC.UserTiers, min: MoneyValue, max: MoneyValue) -> PendingTransaction in
                var pendingTransaction = pendingTransaction
                pendingTransaction.minimumApiLimit = min
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                pendingTransaction.maximumLimit = max
                pendingTransaction.engineState[.userTiers] = tiers
                return pendingTransaction
            }
    }

    func doValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultDoValidateAll(pendingTransaction: pendingTransaction)
    }

    func defaultDoValidateAll(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        validateAmount(pendingTransaction: pendingTransaction)
    }

    func validateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        defaultValidateAmount(pendingTransaction: pendingTransaction)
    }

    func defaultValidateAmount(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        doValidateAmount(pendingTransaction: pendingTransaction)
            .updateTxValidityCompletable(pendingTransaction: pendingTransaction)
    }

    func doPostExecute(transactionResult: TransactionResult) -> Completable {
        target.onTxCompleted(transactionResult)
    }

    func doBuildConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        quotesEngine.getRate(direction: orderDirection, pair: pair)
            .first()
            .map(weak: self) { [sourceAsset, targetAsset] (self, pricedQuote) -> PendingTransaction in
                guard let pricedQuote = pricedQuote else {
                    return pendingTransaction // TODO: maybe throw .error()?
                }

                let resultValue = CryptoValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let swapDestinationValue: MoneyValue = try pendingTransaction.amount.convert(using: resultValue)
                let confirmations: [TransactionConfirmation] = [
                    .swapSourceValue(.init(cryptoValue: pendingTransaction.amount.cryptoValue!)),
                    .swapDestinationValue(.init(cryptoValue: swapDestinationValue.cryptoValue!)),
                    .swapExchangeRate(.init(baseValue: .one(currency: sourceAsset), resultValue: resultValue)),
                    .source(.init(value: self.sourceAccount.label)),
                    .destination(.init(value: self.target.label)),
                    .networkFee(.init(
                        fee: pricedQuote.networkFee,
                        feeType: .withdrawalFee,
                        asset: targetAsset.currency
                    )),
                    .networkFee(.init(
                        fee: pendingTransaction.feeAmount,
                        feeType: .depositFee,
                        asset: sourceAsset.currency
                    ))
                ]

                var pendingTransaction = pendingTransaction.update(confirmations: confirmations)
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                return pendingTransaction
            }
    }

    func startConfirmationsUpdate(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        startQuotesFetchingIfNotStarted(pendingTransaction: pendingTransaction)
    }

    private func startQuotesFetchingIfNotStarted(pendingTransaction oldValue: PendingTransaction) -> Single<PendingTransaction> {
        guard oldValue.quoteSubscription == nil else {
            return .just(oldValue)
        }
        var pendingTransaction = oldValue
        pendingTransaction.engineState[.quoteSubscription] = startQuotesFetching()
        return .just(pendingTransaction)
    }

    private func startQuotesFetching() -> Disposable {
        quotesEngine
            .getRate(direction: orderDirection, pair: pair)
            .do(onNext: { [weak self] _ in
                _ = self?.askForRefreshConfirmation(true).subscribe()
            })
            .subscribe()
    }

    func doRefreshConfirmations(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        quotesEngine
            .getRate(direction: orderDirection, pair: pair)
            .take(1)
            .asSingle()
            .map { [targetAsset, sourceAsset] pricedQuote -> PendingTransaction in
                let networkFee = TransactionConfirmation.Model.NetworkFee(
                    fee: pricedQuote.networkFee,
                    feeType: .withdrawalFee,
                    asset: targetAsset.currency
                )
                let resultValue = CryptoValue(amount: pricedQuote.price, currency: targetAsset).moneyValue
                let swapExchangeRate = TransactionConfirmation.Model.SwapExchangeRate(
                    baseValue: CryptoValue.one(currency: sourceAsset).moneyValue,
                    resultValue: resultValue
                )
                let swapDestinationValue = TransactionConfirmation.Model.SwapDestinationValue(
                    cryptoValue: (try pendingTransaction.amount.convert(using: resultValue)).cryptoValue!
                )

                var pendingTransaction = pendingTransaction
                    .insert(confirmation: .networkFee(networkFee))
                    .insert(confirmation: .swapExchangeRate(swapExchangeRate))
                    .insert(confirmation: .swapDestinationValue(swapDestinationValue))
                pendingTransaction.minimumLimit = try pendingTransaction.calculateMinimumLimit(for: pricedQuote)
                return pendingTransaction
            }
    }

    // MARK: - SwapTransactionEngine

    func createOrder(pendingTransaction: PendingTransaction) -> Single<SwapOrder> {
        Single.zip(
            target.receiveAddress,
            sourceAccount.receiveAddress
        )
        .map { ($0.0.address, $0.1.address) }
        .flatMap(weak: self) { (self, addresses) -> Single<SwapOrder> in
            let (destinationAddress, refundAddress) = addresses
            return self.orderQuoteRepository
                .fetchQuote(
                    direction: self.orderDirection,
                    sourceCurrencyType: self.sourceAsset,
                    destinationCurrencyType: self.target.currencyType
                )
                .asObservable()
                .asSingle()
                .flatMap(weak: self) { (self, quote) -> Single<SwapOrder> in
                    let destination = self.orderDirection.requiresDestinationAddress ? destinationAddress : nil
                    let refund = self.orderDirection.requiresRefundAddress ? refundAddress : nil
                    return self.orderCreationRepository
                        .createOrder(
                            direction: self.orderDirection,
                            quoteIdentifier: quote.identifier,
                            volume: pendingTransaction.amount,
                            destinationAddress: destination,
                            refundAddress: refund
                        )
                        .asObservable()
                        .asSingle()
                }
        }
        .do(onDispose: { [weak self] in
            self?.disposeQuotesFetching(pendingTransaction: pendingTransaction)
        })
    }

    // MARK: - Private Functions

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

    private var destinationExchangeRatePair: Single<MoneyValuePair> {
        fiatCurrencyService
            .fiatCurrency
            .flatMap(weak: self) { (self, fiatCurrency) -> Single<MoneyValuePair> in
                self.priceService
                    .price(of: self.target.currencyType, in: fiatCurrency)
                    .asSingle()
                    .map(\.moneyValue)
                    .map { MoneyValuePair(base: .one(currency: self.target.currencyType), quote: $0) }
            }
    }

    private func doValidateAmount(pendingTransaction: PendingTransaction) -> Completable {
        sourceAccount
            .actionableBalance
            .map(weak: self) { (self, balance) -> Void in
                guard try pendingTransaction.amount <= balance else {
                    throw TransactionValidationFailure(state: .insufficientFunds)
                }
                guard let minimumLimit = pendingTransaction.minimumLimit else {
                    Logger.shared.error("Minimum Limit is nil: \(pendingTransaction)")
                    throw TransactionValidationFailure(state: .unknownError)
                }
                guard let maximumLimit = pendingTransaction.maximumLimit else {
                    Logger.shared.error("Maximum Limit is nil: \(pendingTransaction)")
                    throw TransactionValidationFailure(state: .unknownError)
                }
                guard try pendingTransaction.amount >= minimumLimit else {
                    throw TransactionValidationFailure(state: .belowMinimumLimit)
                }
                guard try pendingTransaction.amount <= maximumLimit else {
                    throw self.validationFailureForTier(pendingTransaction: pendingTransaction)
                }
            }
            .asCompletable()
    }

    private func validationFailureForTier(pendingTransaction: PendingTransaction) -> TransactionValidationFailure {
        guard let userTiers = pendingTransaction.userTiers else {
            return TransactionValidationFailure(state: .unknownError)
        }
        if userTiers.isTier2Approved {
            return TransactionValidationFailure(state: .overGoldTierLimit)
        }
        return TransactionValidationFailure(state: .overSilverTierLimit)
    }
}

extension PendingTransaction {

    fileprivate func calculateMinimumLimit(for quote: PricedQuote) throws -> MoneyValue {
        guard let minimumApiLimit = minimumApiLimit else {
            return MoneyValue.zero(currency: quote.networkFee.currencyType)
        }
        let destination = quote.networkFee.currencyType
        let source = amount.currencyType
        let price = MoneyValue(amount: quote.price, currency: destination)
        let totalFees = (try? quote.networkFee + quote.staticFee) ?? MoneyValue.zero(currency: destination)
        let convertedFees = try totalFees.convert(usingInverse: price, currencyType: source)
        return (try? minimumApiLimit + convertedFees) ?? MoneyValue.zero(currency: destination)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == PendingTransaction {

    /// Checks if `pendingOrdersLimitReached` error occured and passes that down the stream, otherwise
    ///  - in case the error is not a `NabuNetworkError` it throws the erro
    ///  - if the error is a `NabuNetworkError` and it is not a `pendingOrdersLimitReached`,
    ///    it passes a `nabuError` which contains the raw nabu error
    /// - Parameter initialValue: The current `PendingTransaction` to be updated
    /// - Returns: An `Single<PendingTransaction>` with updated `validationState`
    func handleSwapPendingOrdersError(initialValue: PendingTransaction) -> Single<PendingTransaction> {
        catchError { error -> Single<PendingTransaction> in
            guard let networkError = error as? NabuNetworkError else {
                throw error
            }
            guard case .nabuError(let nabuError) = networkError else {
                throw error
            }
            guard nabuError.code == .pendingOrdersLimitReached else {
                var initialValue = initialValue
                initialValue.validationState = .nabuError(nabuError)
                return .just(initialValue)
            }
            var initialValue = initialValue
            initialValue.validationState = .pendingOrdersLimitReached
            return .just(initialValue)
        }
    }
}
