// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

protocol InterestAccountBalanceClientAPI: AnyObject {
    func fetchBalanceWithFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountBalanceResponse?, NabuNetworkError>
}
