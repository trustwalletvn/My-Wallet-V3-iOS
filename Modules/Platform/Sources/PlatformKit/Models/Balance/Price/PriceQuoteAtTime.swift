// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PriceQuoteAtTime: Equatable {

    /// The time stamp of the quote
    public let timestamp: Date

    /// The quote value
    public let moneyValue: MoneyValue
}

extension PriceQuoteAtTime {

    /// Initialize the quote with the network response
    /// - Parameters:
    ///   - response: The quote response
    ///   - currency: The conversion currency of the quote
    /// - Throws: Money value initialization error.
    public init(response: PriceQuoteAtTimeResponse, currency: Currency) throws {
        moneyValue = MoneyValue.create(major: "\(response.price)", currency: currency.currency)!
        timestamp = response.timestamp
    }
}
