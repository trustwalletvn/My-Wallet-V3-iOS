// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

protocol InterestAccountEligibilityClientAPI: AnyObject {
    func fetchInterestAccountEligibilityResponse()
        -> AnyPublisher<InterestEligibilityResponse, NabuNetworkError>
}
