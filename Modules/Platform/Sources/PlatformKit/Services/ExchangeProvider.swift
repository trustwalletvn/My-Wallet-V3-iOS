// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

    private var services: [CurrencyType: PairExchangeServiceAPI] = [:]

    // MARK: - Setup

    public init(
        fiats: [FiatCurrency: PairExchangeServiceAPI],
        cryptos: [CryptoCurrency: PairExchangeServiceAPI]
    ) {
        for (currency, service) in fiats {
            services[.fiat(currency)] = service
        }
        for (currency, service) in cryptos {
            services[.crypto(currency)] = service
        }
    }

    public func refresh() {
        services.values.forEach { $0.fetchTriggerRelay.accept(()) }
    }
}
