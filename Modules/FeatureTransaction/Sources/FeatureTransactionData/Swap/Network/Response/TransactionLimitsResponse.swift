// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit

struct TransactionLimitsResponse: Decodable {

    enum CodingKeys: String, CodingKey {
        case currency
        case minOrder
        case maxOrder
        case maxPossibleOrder
        case daily
        case weekly
        case annual
    }

    struct Limit: Decodable {
        let limit: String
        let available: String
        let used: String
    }

    let currency: FiatCurrency
    let minOrder: FiatValue
    let maxOrder: FiatValue
    let maxPossibleOrder: FiatValue
    let daily: TransactionLimit?
    let weekly: TransactionLimit?
    let annual: TransactionLimit?

    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        currency = try values.decode(FiatCurrency.self, forKey: .currency)
        let zero = FiatValue.zero(currency: currency)

        minOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .minOrder),
            currency: currency
        ) ?? zero
        maxPossibleOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .maxPossibleOrder),
            currency: currency
        ) ?? zero
        maxOrder = FiatValue.create(
            minor: try values.decode(String.self, forKey: .maxOrder),
            currency: currency
        ) ?? zero

        if let daily = try values.decodeIfPresent(Limit.self, forKey: .daily) {
            self.daily = .init(fiatCurrency: currency, limit: daily)
        } else {
            daily = nil
        }
        if let weekly = try values.decodeIfPresent(Limit.self, forKey: .weekly) {
            self.weekly = .init(fiatCurrency: currency, limit: weekly)
        } else {
            weekly = nil
        }
        if let annual = try values.decodeIfPresent(Limit.self, forKey: .annual) {
            self.annual = .init(fiatCurrency: currency, limit: annual)
        } else {
            annual = nil
        }
    }
}

extension TransactionLimits {

    init(response: TransactionLimitsResponse) {
        self.init(
            currency: response.currency,
            minOrder: response.minOrder,
            maxOrder: response.maxOrder,
            maxPossibleOrder: response.maxPossibleOrder,
            daily: response.daily,
            weekly: response.weekly,
            annual: response.annual
        )
    }
}

extension TransactionLimit {

    fileprivate init(
        fiatCurrency: FiatCurrency,
        limit: TransactionLimitsResponse.Limit
    ) {
        self.init(
            limit: FiatValue
                .create(
                    minor: limit.limit,
                    currency: fiatCurrency
                ) ?? .zero(currency: fiatCurrency),
            available: FiatValue
                .create(
                    minor: limit.available,
                    currency: fiatCurrency
                ) ?? .zero(currency: fiatCurrency),
            used: FiatValue
                .create(
                    minor: limit.used,
                    currency: fiatCurrency
                ) ?? .zero(currency: fiatCurrency)
        )
    }
}
