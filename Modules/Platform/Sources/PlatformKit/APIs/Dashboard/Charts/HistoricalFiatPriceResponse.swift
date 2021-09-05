// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// `HistoricalFiatPriceResponse` is only used with `HistoricalFiatPriceServiceAPI`.
public struct HistoricalFiatPriceResponse {

    /// The prices for the given `PriceWindow`
    public let historicalPrices: HistoricalPriceSeries

    /// The current `FiatValue` of the CryptoCurrency. This is **not** the `.last`
    /// value in `HistoricalPriceSeries`. This is fetched separately from a different service.
    public let currentFiatValue: FiatValue

    /// The `PriceWindow`
    public let priceWindow: PriceWindow

    // MARK: - Init

    public init(prices: HistoricalPriceSeries, fiatValue: FiatValue, priceWindow: PriceWindow) {
        historicalPrices = prices
        currentFiatValue = fiatValue
        self.priceWindow = priceWindow
    }
}
