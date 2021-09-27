// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public enum InterestAccountLimitsError: Error {
    case networkError(Error)
    case interestAccountLimitsUnavailable
}

public protocol InterestAccountLimitsRepositoryAPI {

    /// Fetches all `CryptoCurrency` `InterestAccountLimits` for a given `FiatCurrency`.
    /// - Parameter fiatCurrency: The user's `FiatCurrency`
    func fetchInterestAccountLimitsForAllAssets(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<[InterestAccountLimits], InterestAccountLimitsError>

    /// Fetches `InterestAccountLimits` for a given `CryptoCurrency`.
    /// - Parameter cryptoCurrency: CryptoCurrency
    /// - Parameter fiatCurrency: The user's `FiatCurrency`
    func fetchInterestAccountLimitsForCryptoCurrency(
        _ cryptoCurrency: CryptoCurrency,
        fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountLimits, InterestAccountLimitsError>
}
