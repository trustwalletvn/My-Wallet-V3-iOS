// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Entry point for observing any incoming notification within the app
public protocol RemoteNotificationEmitting: AnyObject {
    /// An `Observable` of remote notification type
    var notification: Observable<RemoteNotification.NotificationType> { get }
}
