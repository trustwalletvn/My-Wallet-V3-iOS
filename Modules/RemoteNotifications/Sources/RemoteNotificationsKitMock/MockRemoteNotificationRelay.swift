// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift
import UIKit

@testable import RemoteNotificationsKit

final class MockRemoteNotificationRelay: RemoteNotificationEmitting, RemoteNotificationBackgroundReceiving {

    let relay = PublishRelay<RemoteNotification.NotificationType>()
    var notification: Observable<RemoteNotification.NotificationType> {
        relay.asObservable()
    }

    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        completionHandler(.noData)
    }
}
