// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines a configuration for a given `AppFeature`
public struct AppFeatureConfiguration {

    /// To be thrown if necessary when the feature is not remotely disabled
    public enum ConfigError: Error {

        /// Feature is remotely disabled
        case disabled
    }

    public let isEnabled: Bool

    public init(isEnabled: Bool) {
        self.isEnabled = isEnabled
    }
}
