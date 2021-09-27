// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

/// A service for fetching fiat prices.
public protocol FiatPriceServiceAPI {

    /// Get the historic price
    func getPrice(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        date: Date
    ) -> Single<MoneyValue>

    func getPrice(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency
    ) -> Single<MoneyValue>
}

final class FiatPriceService: FiatPriceServiceAPI {

    private struct CacheKey: Hashable {
        let cryptoCurrency: CryptoCurrency
        let fiatCurrency: FiatCurrency
        let date: Date
    }

    private let cache: Atomic<[CacheKey: MoneyValue]> = .init([:])
    private let priceService: PriceServiceAPI

    init(priceService: PriceServiceAPI = resolve()) {
        self.priceService = priceService
    }

    func getPrice(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency
    ) -> Single<MoneyValue> {
        getPrice(cryptoCurrency: cryptoCurrency, fiatCurrency: fiatCurrency, date: Date())
    }

    func getPrice(
        cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency,
        date: Date
    ) -> Single<MoneyValue> {
        // Create cache key with normalised date.
        let cacheKey = CacheKey(cryptoCurrency: cryptoCurrency, fiatCurrency: fiatCurrency, date: normalizeDate(date))
        if let cached = cache.value[cacheKey] {
            return .just(cached)
        }
        return priceService
            .price(of: cryptoCurrency.currency, in: fiatCurrency.currency, at: date)
            .asSingle()
            .map(\.moneyValue)
            .do(onSuccess: { [weak self] price in
                self?.cache.mutate { value in
                    value[cacheKey] = price
                }
            })
    }

    /// Normalizes a given date into one minutes blocks, this is used so we can
    /// hit cached data when retrieving a resource from the same block as previously fetched request.
    private func normalizeDate(_ date: Date) -> Date {
        let factor: TimeInterval = 60
        let timeIntervalSince1970: TimeInterval = factor * floor(date.timeIntervalSince1970 / factor)
        return Date(timeIntervalSince1970: timeIntervalSince1970)
    }
}
