// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import RemoteNotificationsKit
import UserNotifications

final class MockUNUserNotificationCenter: UNUserNotificationCenterAPI {

    struct FakeError: Error {
        let info: String
    }

    weak var delegate: UNUserNotificationCenterDelegate?

    private let initialAuthorizationStatus: UNAuthorizationStatus
    private let expectedAuthorizationResult: Result<Bool, FakeError>

    init(
        initialAuthorizationStatus: UNAuthorizationStatus,
        expectedAuthorizationResult: Result<Bool, FakeError>
    ) {
        self.initialAuthorizationStatus = initialAuthorizationStatus
        self.expectedAuthorizationResult = expectedAuthorizationResult
    }

    func getAuthorizationStatus(completionHandler: @escaping (UNAuthorizationStatus) -> Void) {
        completionHandler(initialAuthorizationStatus)
    }

    func getNotificationSettings(completionHandler: @escaping (UNNotificationSettings) -> Void) {}

    func requestAuthorization(options: UNAuthorizationOptions, completionHandler: @escaping (Bool, Error?) -> Void) {
        switch expectedAuthorizationResult {
        case .success(let isGranted):
            completionHandler(isGranted, nil)
        case .failure(let error):
            completionHandler(false, error)
        }
    }
}
