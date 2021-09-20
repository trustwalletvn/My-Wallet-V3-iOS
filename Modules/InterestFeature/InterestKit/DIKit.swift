// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit

extension DependencyContainer {

    // MARK: - InterestKit Module

    public static var interestKit = module {

        single { InterestAccountService() as InterestAccountServiceAPI }

        factory { () -> InterestAccountOverviewAPI in
            let service: InterestAccountServiceAPI = DIKit.resolve()
            return service as InterestAccountOverviewAPI
        }
    }
}
