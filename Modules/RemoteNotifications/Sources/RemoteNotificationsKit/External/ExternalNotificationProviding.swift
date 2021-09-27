// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

/// Aggregrates any external service notification logic
public protocol ExternalNotificationProviding: AnyObject {
    /// A `Single` that streams the token value if exist and not empty or `nil`.
    /// Throws an error (`RemoteNotificationTokenFetchError`) in case the service has failed or if the token came out empty.
    var token: Single<String> { get }
    /// Let the messaging service know about the new token
    func didReceiveNewApnsToken(token: Data)
    /// Subscribes to a given topic so the client will be able to receive notifications for it.
    /// - Parameter topic: the topic that the client should subscribe to.
    /// - Returns: A `Single` acknowledges the subscription.
    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void>
}
