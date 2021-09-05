// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol InterestAccountEligibilityRepositoryAPI {

    /// Fetches all `InterestAccountEligibility` objects.
    func fetchAllInterestAccountEligibility()
        -> AnyPublisher<[InterestAccountEligibility], InterestAccountEligibilityError>

    /// Fetches an `InterestAccountEligibility` object for a given
    /// currency code.
    /// - Parameter code: A currency code
    func fetchInterestAccountEligibilityForCurrencyCode(
        _ code: String
    ) -> AnyPublisher<InterestAccountEligibility, InterestAccountEligibilityError>
}
