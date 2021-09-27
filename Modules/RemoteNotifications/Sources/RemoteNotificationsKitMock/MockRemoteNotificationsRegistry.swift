// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import RemoteNotificationsKit
import XCTest

final class MockRemoteNotificationsRegistry: UIApplicationRemoteNotificationsAPI {

    private(set) var isRegistered = false

    func registerForRemoteNotifications() {
        isRegistered = true
    }
}
