// Copyright © Blockchain Luxembourg S.A. All rights reserved.

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

    public init(services: [CryptoCurrency: HistoricalFiatPriceServiceAPI]) {
        self.services = services
        refresh()
    }

    public func refresh(window: PriceWindow = .day(.oneHour)) {
        services.values.forEach { $0.fetchTriggerRelay.accept(window) }
    }
}
