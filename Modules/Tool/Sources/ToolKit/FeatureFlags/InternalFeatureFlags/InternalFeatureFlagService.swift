// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol InternalFeatureFlagServiceAPI {
    func isEnabled(_ feature: InternalFeature) -> Bool
    func enable(_ feature: InternalFeature)
    func enable(_ features: [InternalFeature])
    func disable(_ feature: InternalFeature)
}

final class InternalFeatureFlagService: InternalFeatureFlagServiceAPI {

    private let defaults: UserDefaults

    init(defaultsProvider: () -> UserDefaults) {
        defaults = defaultsProvider()
    }

    func enable(_ feature: InternalFeature) {
        defaults.setValue(true, forKey: feature.defaultsKey)
    }

    func disable(_ feature: InternalFeature) {
        defaults.setValue(false, forKey: feature.defaultsKey)
    }

    func enable(_ features: [InternalFeature]) {
        features.forEach(enable(_:))
    }

    func isEnabled(_ feature: InternalFeature) -> Bool {
        defaults.bool(forKey: feature.defaultsKey)
    }
}

/// Provides the internal user defaults
/// - Returns: A custom `UserDefaults` or in case of failure the `UserDefaults.standard`
internal func provideInternalUserDefaults() -> UserDefaults {
    guard let userDefaults = UserDefaults(suiteName: "blockchain.internal.feature.flag.storage") else {
        return UserDefaults.standard
    }
    return userDefaults
}
