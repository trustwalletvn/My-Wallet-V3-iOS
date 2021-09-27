// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

final class EphemeralFeatureFlagService: InternalFeatureFlagServiceAPI {

    private var flags: [InternalFeature: Bool] = [:]

    func isEnabled(_ feature: InternalFeature) -> Bool {
        flags[feature] ?? false
    }

    func enable(_ feature: InternalFeature) {
        flags[feature] = true
    }

    func enable(_ features: [InternalFeature]) {
        features.forEach(enable(_:))
    }

    func disable(_ feature: InternalFeature) {
        flags[feature] = false
    }
}
