// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift
import UserNotifications

public typealias RemoteNotificationAuthorizing = RemoteNotificationRegistering &
    RemoteNotificationAuthorizationRequesting &
    RemoteNotificationAuthorizationStatusProviding

/// A protocol that encapsulates the registration to any notification service
/// The app delegate should hold its instance and inform it about registration events.
public protocol RemoteNotificationRegistering: AnyObject {
    /// Registers for remote notifications ONLY if the authorization status is `.authorized`.
    /// Should be called at the application startup after first initializing Firebase Messaging.
    func registerForRemoteNotificationsIfAuthorized() -> Single<Void>
}

/// A protocol that defines remote-notification authorization / registration methods
public protocol RemoteNotificationAuthorizationRequesting: AnyObject {
    /// Request authorization for remote notifications if the status is not yet determined.
    func requestAuthorizationIfNeeded() -> Single<Void>
    func requestAuthorizationIfNeededPublisher() -> AnyPublisher<Never, Error>
}

/// A protocol that defines remote-notification auth-status reading abilities
public protocol RemoteNotificationAuthorizationStatusProviding {
    /// A `Single` that streams the authorization status of the notifications, on demand.
    var status: Single<UNAuthorizationStatus> { get }
    /// A `Single` that streams a boolean value indicating whether `status` is authorized
    /// A default implementation that depends on the status
    var isAuthorized: Single<Bool> { get }
}

extension RemoteNotificationAuthorizationStatusProviding {
    public var isAuthorized: Single<Bool> {
        status.map { $0 == .authorized }
    }
}
