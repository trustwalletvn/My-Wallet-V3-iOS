// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A cache refresh control.
public protocol CacheRefreshControl {

    /// Returns a `Boolean` value indicating whether the cache value should be refreshed.
    ///
    /// - Parameter lastRefresh: The time when the cache value was last refreshed.
    func shouldRefresh(lastRefresh: Date) -> Bool
}

/// A periodic cache refresh control, checking cache values that should be refreshed based on a given refresh interval.
public final class PeriodicCacheRefreshControl: CacheRefreshControl {

    // MARK: - Private Properties

    /// The refresh interval.
    /// Cache values with a `lastRefresh` time older than the start of this interval, relative to the current time, should be refreshed.
    private let refreshInterval: TimeInterval

    // MARK: - Setup

    /// Creates a periodic cache refresh control.
    ///
    /// - Parameter refreshInterval: A refresh interval.
    public init(refreshInterval: TimeInterval) {
        self.refreshInterval = refreshInterval
    }

    // MARK: - Public Methods

    public func shouldRefresh(lastRefresh: Date) -> Bool {
        lastRefresh < Date(timeIntervalSinceNow: -refreshInterval)
    }
}
