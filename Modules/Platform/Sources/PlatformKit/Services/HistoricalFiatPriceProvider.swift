// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public protocol HistoricalFiatPriceProviding: AnyObject {

    /// Returns the service that matches the `CryptoCurrency`
    subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI { get }
    func refresh(window: PriceWindow)
}

public final class HistoricalFiatPriceProvider: HistoricalFiatPriceProviding {

    public subscript(currency: CryptoCurrency) -> HistoricalFiatPriceServiceAPI {
        services[currency]!
    }

    // MARK: - Services

    private let services: [CryptoCurrency: HistoricalFiatPriceServiceAPI]

    // MARK: - Setup

    public init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        exchangeProvider: ExchangeProviding = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        services = enabledCurrenciesService
            .allEnabledCryptoCurrencies
            .reduce(into: [CryptoCurrency: HistoricalFiatPriceServiceAPI]()) { result, cryptoCurrency in
                result[cryptoCurrency] = HistoricalFiatPriceService(
                    cryptoCurrency: cryptoCurrency,
                    exchangeAPI: exchangeProvider[cryptoCurrency],
                    fiatCurrencyService: fiatCurrencyService
                )
            }

        refresh()
    }

    public func refresh(window: PriceWindow = .day(.oneHour)) {
        services.values.forEach { service in
            service.fetchTriggerRelay.accept(window)
        }
    }
}
