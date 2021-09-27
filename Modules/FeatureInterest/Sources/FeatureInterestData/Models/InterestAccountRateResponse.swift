// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestDomain

struct InterestAccountRateResponse: Decodable {
    let currency: String
    let rate: Double
}

extension InterestAccountRate {
    init(_ response: InterestAccountRateResponse) {
        self.init(
            currencyCode: response.currency,
            rate: response.rate
        )
    }
}
