// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public typealias RemoteNotificationTokenFetchResult = Result<RemoteNotification.Token, RemoteNotification.TokenFetchError>

/// This is used to separate firebase from the rest of the remote notification logic
public protocol RemoteNotificationTokenFetching: AnyObject {

    /**
     Asynchronously retrieves the Remote Notification registration token, used for receiving notifications to the device.

     - Parameter handler: The closure for handling the asynchronous response.
     */
    func token(handler: @escaping (RemoteNotificationTokenFetchResult) -> Void)
}
