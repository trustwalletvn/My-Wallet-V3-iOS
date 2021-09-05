// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

extension CachedValueConfiguration {

    /// Refresh `.onSubscription` (only when cache is empty) and
    /// flushes the cached value on login and logout.
    public static func onSubscription(
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .onSubscription,
            scheduler: scheduler,
            flushNotificationNames: [.login, .logout]
        )
    }

    /// Refresh `.periodic` by the given `TimeInterval` and
    /// flushes the cached value on login and logout.
    public static func periodic(
        _ time: TimeInterval,
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) -> CachedValueConfiguration {
        CachedValueConfiguration(
            refreshType: .periodic(seconds: time),
            scheduler: scheduler,
            flushNotificationNames: [.login, .logout]
        )
    }
}
