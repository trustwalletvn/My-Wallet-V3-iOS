// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import UIKit

/// A protocol that encapsulates the sending of a pre-known notification token
public protocol RemoteNotificationTokenSending: AnyObject {
    /// Sends the token. Only if remote notification permission was pre-authorized.
    /// Typically called after the user has identified himself with his PIN since the
    /// user credentials are known at that time
    func sendTokenIfNeeded() -> Single<Void>
    func sendTokenIfNeededPublisher() -> AnyPublisher<Never, Error>
}

/// A protocol defining an object that reacts to the registration, or failure, of remote notifications.
public protocol RemoteNotificationDeviceTokenReceiving: AnyObject {
    func appDidFailToRegisterForRemoteNotifications(with error: Error)
    func appDidRegisterForRemoteNotifications(with deviceToken: Data)
}

/// A protocol that defines an object that receives data/background notifications ( "remote-notification" background mode).
public protocol RemoteNotificationBackgroundReceiving: AnyObject {
    /// Method should be called when application receives a background notification.
    /// - Parameters:
    ///   - userInfo: Notification payload.
    ///   - applicationState: `UIApplication` state.
    ///   - completionHandler: `completionHandler` that will be called when any work is completed.
    func didReceiveRemoteNotification(
        _ userInfo: [AnyHashable: Any],
        onApplicationState applicationState: UIApplication.State,
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    )
}

/// An umbrella protocol that represents a single entry to common notification services
protocol RemoteNotificationServicing: AnyObject {
    var relay: RemoteNotificationEmitting { get }
    var backgroundReceiver: RemoteNotificationBackgroundReceiving { get }
    var authorizer: RemoteNotificationAuthorizing { get }
}
