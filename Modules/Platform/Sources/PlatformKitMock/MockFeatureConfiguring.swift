// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import ToolKit

class MockFeatureConfigurator: FeatureConfiguratorAPI {

    var featureIsEnabled: Bool = false

    var initializeCalled = false

    func initialize() {
        initializeCalled = true
    }

    func configuration(for feature: AppFeature) -> AppFeatureConfiguration {
        AppFeatureConfiguration(isEnabled: featureIsEnabled)
    }

    func configuration<Feature>(
        for feature: AppFeature
    ) -> Result<Feature, FeatureConfigurationError> where Feature: Decodable {
        .failure(.decodingError)
    }
}
