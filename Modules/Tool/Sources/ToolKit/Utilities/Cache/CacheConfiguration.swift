// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A cache configuration.
public final class CacheConfiguration {

    // MARK: - Public Properties

    /// The flush notification names.
    ///
    /// When any of these notifications is received, the cache must be flushed (all values must be removed).
    let flushNotificationNames: [Notification.Name]

    // MARK: - Setup

    /// Creates a cache configuration.
    ///
    /// - Parameters:
    ///   - flushNotificationNames: An array of flush notification names.
    public init(flushNotificationNames: [Notification.Name] = []) {
        self.flushNotificationNames = flushNotificationNames
    }
}

extension CacheConfiguration {

    /// Creates a default cache configuration with no flush notification names.
    public static func `default`() -> CacheConfiguration {
        CacheConfiguration()
    }
}
