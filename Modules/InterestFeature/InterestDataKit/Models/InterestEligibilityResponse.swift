// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import InterestKit
import PlatformKit

struct InterestEligibilityResponse: Decodable {

    // MARK: - Properties

    let interestEligibilities: [String: InterestEligibility]

    // MARK: - Init

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        interestEligibilities = try container.decode([String: InterestEligibility].self)
    }

    // MARK: - Subscript

    subscript(currencyType: CurrencyType) -> InterestEligibility? {
        interestEligibilities[currencyType.code]
    }
}
