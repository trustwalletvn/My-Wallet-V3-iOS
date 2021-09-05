// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

extension DependencyContainer {

    // MARK: - ToolKit Module

    public static var toolKit = module {

        factory { UserDefaults.standard as CacheSuite }

        // MARK: - Internal Feature Flag

        factory { InternalFeatureFlagService(defaultsProvider: provideInternalUserDefaults) as InternalFeatureFlagServiceAPI }

        factory { FeatureFlagsService() as FeatureFlagsServiceAPI }

        factory { FileIO() as FileIOAPI }
    }
}
