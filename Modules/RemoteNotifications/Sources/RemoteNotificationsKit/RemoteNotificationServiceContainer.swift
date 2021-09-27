// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Remote notification service container provides maximum abstraction
/// for notification authorization, registration, sending and emitting services.
public protocol RemoteNotificationServiceContaining {
    var authorizer: RemoteNotificationAuthorizing { get }
    var backgroundReceiver: RemoteNotificationBackgroundReceiving { get }
    var tokenSender: RemoteNotificationTokenSending { get }
    var tokenReceiver: RemoteNotificationDeviceTokenReceiving { get }
}

final class RemoteNotificationServiceContainer: RemoteNotificationServiceContaining {

    // MARK: - Types

    typealias Service = RemoteNotificationServicing & RemoteNotificationTokenSending & RemoteNotificationDeviceTokenReceiving

    // MARK: - Properties

    /// Emitter of notification enums
    var emitter: RemoteNotificationEmitting {
        service.relay
    }

    /// Authorizer of remote notifications
    var authorizer: RemoteNotificationAuthorizing {
        service.authorizer
    }

    /// Receiver of data/background notifications
    var backgroundReceiver: RemoteNotificationBackgroundReceiving {
        service.backgroundReceiver
    }

    /// Token sender
    var tokenSender: RemoteNotificationTokenSending {
        service
    }

    /// Token receiver
    var tokenReceiver: RemoteNotificationDeviceTokenReceiving {
        service
    }

    /// Aggregates common remote notification logic
    private let service: Service

    // MARK: - Setup

    init(service: Service = RemoteNotificationService()) {
        self.service = service
    }
}
