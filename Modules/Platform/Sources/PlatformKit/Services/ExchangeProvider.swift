// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

/// A provider for exchange rates as per supported crypto.
public protocol ExchangeProviding: AnyObject {

    /// Returns the exchange service
    subscript(currency: Currency) -> PairExchangeServiceAPI { get }

    subscript(currency: CryptoCurrency) -> PairExchangeServiceAPI { get }

    subscript(currency: FiatCurrency) -> PairExchangeServiceAPI { get }

    /// Refreshes all the exchange rates
    func refresh()
}

public final class ExchangeProvider: ExchangeProviding {

    public subscript(currency: Currency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }

    public subscript(currency: CryptoCurrency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }

    public subscript(currency: FiatCurrency) -> PairExchangeServiceAPI {
        services[currency.currency]!
    }

    // MARK: - Services

    private let services: [CurrencyType: PairExchangeServiceAPI]

    // MARK: - Setup

    public init(
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve()
    ) {
        services = enabledCurrenciesService
            .allEnabledCurrencies
            .reduce(into: [CurrencyType: PairExchangeServiceAPI]()) { result, currencyType in
                result[currencyType] = PairExchangeService(
                    currency: currencyType,
                    fiatCurrencyService: fiatCurrencyService
                )
            }
    }

    public func refresh() {
        services.values.forEach { service in
            service.fetchTriggerRelay.accept(())
        }
    }
}
