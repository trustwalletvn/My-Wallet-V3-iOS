// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import AnalyticsKit
import DIKit
import PlatformKit
@testable import RemoteNotificationsKit
// import RxBlocking
import RxSwift
import UserNotifications
import XCTest

#if canImport(RxBlocking)
#error("Uncomment tests.")
#endif

final class RemoteNotificationAuthorizerTests: XCTestCase {

    // MARK: - Test Authorization Request

//    func testSuccessfulAuthorization() {
//        let registry = MockRemoteNotificationsRegistry()
//        let userNotificationCenter = MockUNUserNotificationCenter(
//            initialAuthorizationStatus: .notDetermined,
//            expectedAuthorizationResult: .success(true)
//        )
//        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
//        let authorizer = RemoteNotificationAuthorizer(
//            application: registry,
//            analyticsRecorder: analyticsProvider,
//            userNotificationCenter: userNotificationCenter,
//            options: [.alert, .badge, .sound]
//        )
//        do {
//            try authorizer.requestAuthorizationIfNeeded().toBlocking().first()!
//            XCTAssertTrue(registry.isRegistered)
//        } catch {
//            XCTFail("expected successful registration. got \(error) instead")
//        }
//    }
//
//    func testFailedAuthorizationAfterDenyingPermissions() {
//        let registry = MockRemoteNotificationsRegistry()
//        let userNotificationCenter = MockUNUserNotificationCenter(
//            initialAuthorizationStatus: .notDetermined,
//            expectedAuthorizationResult: .failure(.init(info: "permission denied"))
//        )
//        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
//        let authorizer = RemoteNotificationAuthorizer(
//            application: registry,
//            analyticsRecorder: analyticsProvider,
//            userNotificationCenter: userNotificationCenter,
//            options: [.alert, .badge, .sound]
//        )
//        do {
//            try authorizer.requestAuthorizationIfNeeded().toBlocking().first()!
//            XCTFail("expected error. got success instead")
//        } catch {
//            // Okay
//        }
//
//        XCTAssertFalse(registry.isRegistered)
//    }
//
//    func testFailedAuthorizationWhenPermissionIsAlreadyDetermined() {
//        let registry = MockRemoteNotificationsRegistry()
//        let userNotificationCenter = MockUNUserNotificationCenter(
//            initialAuthorizationStatus: .authorized,
//            expectedAuthorizationResult: .success(true)
//        )
//        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
//        let authorizer = RemoteNotificationAuthorizer(
//            application: registry,
//            analyticsRecorder: analyticsProvider,
//            userNotificationCenter: userNotificationCenter,
//            options: [.alert, .badge, .sound]
//        )
//        do {
//            try authorizer.requestAuthorizationIfNeeded().toBlocking().first()!
//            XCTFail("expected error \(RemoteNotificationAuthorizer.ServiceError.statusWasAlreadyDetermined). got success instead")
//        } catch RemoteNotificationAuthorizer.ServiceError.statusWasAlreadyDetermined {
//            // Okay
//        } catch {
//            XCTFail("expected error \(RemoteNotificationAuthorizer.ServiceError.statusWasAlreadyDetermined). got \(error) instead")
//        }
//
//        XCTAssertFalse(registry.isRegistered)
//    }
//
//    // MARK: - Test Registration If Already Authorized
//
//    func testRegistrationSuccessfulForRemoteNotificationsIfAuthorized() {
//        let registry = MockRemoteNotificationsRegistry()
//        let userNotificationCenter = MockUNUserNotificationCenter(
//            initialAuthorizationStatus: .authorized,
//            expectedAuthorizationResult: .success(true)
//        )
//        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
//        let authorizer = RemoteNotificationAuthorizer(
//            application: registry,
//            analyticsRecorder: analyticsProvider,
//            userNotificationCenter: userNotificationCenter,
//            options: [.alert, .badge, .sound]
//        )
//
//        do {
//            try authorizer.registerForRemoteNotificationsIfAuthorized().toBlocking().first()!
//            XCTAssertTrue(registry.isRegistered)
//        } catch {
//            XCTFail("expected successful registration. got \(error) instead")
//        }
//    }
//
//    func testRegistrationFailureForRemoteNotificationsIfNotAuthorized() {
//        let registry = MockRemoteNotificationsRegistry()
//        let userNotificationCenter = MockUNUserNotificationCenter(
//            initialAuthorizationStatus: .notDetermined,
//            expectedAuthorizationResult: .success(true)
//        )
//        let analyticsProvider = AnalyticsEventRecorder(analyticsServiceProviders: [MockAnalyticsService()])
//        let authorizer = RemoteNotificationAuthorizer(
//            application: registry,
//            analyticsRecorder: analyticsProvider,
//            userNotificationCenter: userNotificationCenter,
//            options: [.alert, .badge, .sound]
//        )
//
//        do {
//            try authorizer.registerForRemoteNotificationsIfAuthorized().toBlocking().first()!
//            XCTFail("expected \(RemoteNotificationAuthorizer.ServiceError.unauthorizedStatus). got success instead")
//            XCTAssertFalse(registry.isRegistered)
//        } catch RemoteNotificationAuthorizer.ServiceError.unauthorizedStatus {
//            // Okay
//        } catch {
//            XCTFail("expected \(RemoteNotificationAuthorizer.ServiceError.unauthorizedStatus). got \(error) instead")
//        }
//    }
}
