// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformUIKit

extension DependencyContainer {

    // MARK: - Blockchain Module

    public static let featureKYCUI = module {
        single { KYCRouter() as KYCRouterAPI }

        factory { KYCTiersPageModelFactory() as KYCTiersPageModelFactoryAPI }
    }
}
