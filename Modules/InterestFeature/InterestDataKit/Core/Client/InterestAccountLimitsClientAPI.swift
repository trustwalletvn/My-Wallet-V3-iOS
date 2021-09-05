// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

protocol InterestAccountLimitsClientAPI: AnyObject {
    func fetchInterestAccountLimitsResponseForFiatCurrency(_ fiatCurrency: FiatCurrency)
        -> AnyPublisher<InterestAccountLimitsResponse, NabuNetworkError>
}
