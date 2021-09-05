// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

public struct TradeLimits: Decodable {
    public let currency: String
    public let minOrder: Decimal
    public let maxOrder: Decimal
    public let maxPossibleOrder: Decimal
    public let daily: Limit?
    public let weekly: Limit?
    public let annual: Limit?

    public var maxTradableToday: Decimal {
        daily?.available ?? maxPossibleOrder
    }

    enum CodingKeys: String, CodingKey {
        case currency
        case minOrder
        case maxOrder
        case maxPossibleOrder
        case daily
        case weekly
        case annual
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decode(String.self, forKey: .currency)
        minOrder = try values.decodeDecimalFromString(forKey: .minOrder)
        maxOrder = try values.decodeDecimalFromString(forKey: .maxOrder)
        maxPossibleOrder = try values.decodeDecimalFromString(forKey: .maxPossibleOrder)
        daily = try values.decodeIfPresent(Limit.self, forKey: .daily)
        weekly = try values.decodeIfPresent(Limit.self, forKey: .weekly)
        annual = try values.decodeIfPresent(Limit.self, forKey: .annual)
    }
}
