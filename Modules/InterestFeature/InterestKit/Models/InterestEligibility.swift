// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct InterestEligibility: Decodable {
    public let isEligible: Bool
    public let ineligibilityReason: String?

    enum CodingKeys: String, CodingKey {
        case isEligible = "eligible"
        case ineligibilityReason
    }
}
