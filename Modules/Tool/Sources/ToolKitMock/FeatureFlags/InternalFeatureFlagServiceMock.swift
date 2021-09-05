// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

final class InternalFeatureFlagServiceMock: InternalFeatureFlagServiceAPI {

    private var features: [InternalFeature: Bool] = [:]

    func isEnabled(_ feature: InternalFeature) -> Bool {
        features[feature] ?? false
    }

    func enable(_ feature: InternalFeature) {
        features[feature] = true
    }

    func enable(_ features: [InternalFeature]) {
        features.forEach(enable)
    }

    func disable(_ feature: InternalFeature) {
        features.removeValue(forKey: feature)
    }
}
