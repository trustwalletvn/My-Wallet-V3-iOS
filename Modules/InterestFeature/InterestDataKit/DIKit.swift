// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import InterestKit

extension DependencyContainer {

    // MARK: - InterestDataKit Module

    public static var interestDataKit = module {

        // MARK: - Data

        factory { APIClient() as InterestDataKitAPIClient }

        factory { () -> InterestAccountEligibilityClientAPI in
            let client: InterestDataKitAPIClient = DIKit.resolve()
            return client as InterestAccountEligibilityClientAPI
        }

        factory { () -> InterestAccountBalanceClientAPI in
            let client: InterestDataKitAPIClient = DIKit.resolve()
            return client as InterestAccountBalanceClientAPI
        }

        factory { () -> InterestAccountLimitsClientAPI in
            let client: InterestDataKitAPIClient = DIKit.resolve()
            return client as InterestAccountLimitsClientAPI
        }

        factory { () -> InterestAccountRateClientAPI in
            let client: InterestDataKitAPIClient = DIKit.resolve()
            return client as InterestAccountRateClientAPI
        }

        factory { InterestAccountEligibilityRepository() as InterestAccountEligibilityRepositoryAPI }

        factory { InterestAccountLimitsRepository() as InterestAccountLimitsRepositoryAPI }

        factory { InterestAccountBalanceRepository() as InterestAccountBalanceRepositoryAPI }

        factory { InterestAccountRateRepository() as InterestAccountRateRepositoryAPI }
    }
}
