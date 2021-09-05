// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxRelay
import RxSwift

/// A Helper object for `CacheValue`
struct CachedValueRefreshControl {

    enum Action {
        case flush
        case fetch
    }

    var shouldRefresh: Bool {
        switch configuration.refreshType {
        case .onSubscription:
            return false
        case .periodic(let refreshInterval):
            let lastRefreshInterval = Date(timeIntervalSinceNow: -refreshInterval)
            let shouldRefresh = lastRefresh.value.compare(lastRefreshInterval) == .orderedAscending
            return shouldRefresh
        case .custom(let shouldRefresh):
            return shouldRefresh()
        }
    }

    var action: Observable<Action> {
        actionRelay.asObservable()
    }

    let actionRelay = PublishRelay<Action>()

    private let lastRefresh = Atomic<Date>(Date.distantPast)
    private let configuration: CachedValueConfiguration

    init(
        configuration: CachedValueConfiguration
    ) {
        self.configuration = configuration

        for notification in configuration.flushNotificationNames {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.flush)
            }
        }

        for notification in configuration.fetchNotificationNames {
            NotificationCenter.when(notification) { [weak actionRelay] _ in
                actionRelay?.accept(.fetch)
            }
        }
    }

    func update(refreshDate: Date) {
        lastRefresh.mutate { $0 = refreshDate }
    }
}
