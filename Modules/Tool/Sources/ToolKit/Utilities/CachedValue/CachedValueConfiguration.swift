// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// A configuration for cached value
public struct CachedValueConfiguration {

    /// A refresh type
    public enum RefreshType {

        /// Refresh once upon the first subscription.
        case onSubscription

        /// Refresh on subscription if cached value is stale.
        case periodic(seconds: TimeInterval)

        /// Custom configuration for refresh
        case custom(() -> Bool)
    }

    let refreshType: RefreshType
    let scheduler: SchedulerType
    let flushNotificationNames: [Notification.Name]
    let fetchNotificationNames: [Notification.Name]

    /**
     Creates a CachedValueConfiguration.

     - Parameter refreshType: A `RefreshType` indicating how the cache will behave.
     - Parameter scheduler: A `SchedulerType` in which the caching logic will be `observeOn` and `subscribeOn`.
     - Parameter flushNotificationNames: A `[Notification.Name]` that will trigger the cached value to be flushed.
     - Parameter fetchNotificationNames: A `[Notification.Name]` that will trigger a refresh.

     */
    public init(
        refreshType: RefreshType,
        scheduler: SchedulerType = generateScheduler(),
        flushNotificationNames: [Notification.Name] = [],
        fetchNotificationNames: [Notification.Name] = []
    ) {
        self.refreshType = refreshType
        self.scheduler = scheduler
        self.flushNotificationNames = flushNotificationNames
        self.fetchNotificationNames = fetchNotificationNames
    }
}

extension CachedValueConfiguration {
    public static func generateScheduler() -> SchedulerType {
        SerialDispatchQueueScheduler(internalSerialQueueName: "internal-\(UUID().uuidString)")
    }
}
