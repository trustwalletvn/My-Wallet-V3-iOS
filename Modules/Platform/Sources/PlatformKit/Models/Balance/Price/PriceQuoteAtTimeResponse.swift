// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit

/// Model for a quoted price by the Service-Price endpoint in fiat for a single asset type.
public struct PriceQuoteAtTimeResponse: Decodable, Equatable {

    public static let empty = PriceQuoteAtTimeResponse(timestamp: .distantPast, price: 0)

    public let timestamp: Date
    public let price: Decimal

    public static func == (lhs: PriceQuoteAtTimeResponse, rhs: PriceQuoteAtTimeResponse) -> Bool {
        lhs.timestamp == rhs.timestamp
            && lhs.price == rhs.price
    }

    public init(timestamp: Date, price: Decimal) {
        self.timestamp = timestamp
        self.price = price
    }
}
