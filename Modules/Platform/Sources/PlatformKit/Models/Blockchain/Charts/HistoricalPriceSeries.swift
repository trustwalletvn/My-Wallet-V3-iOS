// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct HistoricalPriceSeries {
    public let currency: CryptoCurrency

    /// The difference in percentage between the latest price to the first price
    public let delta: Double
    public let deltaPercentage: Double
    public let prices: [PriceQuoteAtTimeResponse]
    public let fiatChange: Decimal

    public init(currency: CryptoCurrency, prices: [PriceQuoteAtTimeResponse]) {
        self.currency = currency
        self.prices = prices
        if let first = prices.first, let latest = prices.last {
            fiatChange = latest.price - first.price
            delta = fiatChange.doubleValue / first.price.doubleValue
        } else {
            fiatChange = 0
            delta = 0
        }
        deltaPercentage = delta * 100
    }
}
