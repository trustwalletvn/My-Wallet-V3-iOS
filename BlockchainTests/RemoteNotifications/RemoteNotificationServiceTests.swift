// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import DIKit
@testable import RemoteNotificationsKit
import RxBlocking
import RxSwift
import XCTest

import NetworkKit
import PlatformKit

final class RemoteNotificationServiceTests: XCTestCase {

    // MARK: - Wide range interaction testing

    func testTokenSendingSuccessUsingRealServices() {

        // Instantiate all the mock services needed to test the notification domain

        let token = "remote-notification-token"
        let registry = MockRemoteNotificationsRegistry()
        let userNotificationCenter = MockUNUserNotificationCenter(
            initialAuthorizationStatus: .authorized,
            expectedAuthorizationResult: .success(true)
        )
        let messagingService = MockMessagingService(expectedTokenResult: .success(token))
        let credentialsProvider = MockGuidSharedKeyRepositoryAPI()
        let networkAdapter = NetworkAdapterMock()
        networkAdapter.response = (filename: "remote-notification-registration-success", bundle: Bundle(for: RemoteNotificationServiceTests.self))

        // Instantiate all the sub services

        let authorizer = RemoteNotificationAuthorizer(
            application: registry,
            analyticsRecorder: resolve(),
            userNotificationCenter: userNotificationCenter,
            options: [.alert, .badge, .sound]
        )
        let relay = RemoteNotificationRelay(
            userNotificationCenter: userNotificationCenter,
            messagingService: messagingService
        )
        let externalServiceProvider = ExternalNotificationServiceProvider(messagingService: messagingService)
        let networkService = RemoteNotificationNetworkService(networkAdapter: networkAdapter)

        // Instantiate the main service

        let service = RemoteNotificationService(
            authorizer: authorizer,
            notificationRelay: relay,
            externalService: externalServiceProvider,
            networkService: networkService,
            sharedKeyRepository: credentialsProvider,
            guidRepository: credentialsProvider
        )

        let observable = service.sendTokenIfNeeded().toBlocking()
        do {
            try observable.first()!
        } catch {
            XCTFail("expected success. got \(error) instead")
        }
    }

    // MARK: - Happy Scenarios using mocks

    func testRegistrationAndTokenSendingAreSuccessfulUsingMockServices() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            notificationRelay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            sharedKeyRepository: MockGuidSharedKeyRepositoryAPI(),
            guidRepository: MockGuidSharedKeyRepositoryAPI()
        )

        let result = service.sendTokenIfNeeded().toBlocking()

        do {
            try result.first()
        } catch {
            XCTFail("expected token to be sent successfully, got \(error) instead")
        }
    }

    // MARK: - Unauthorized permission

    func testTokenSendWithUnauthorizedPermissionsUsingMockServices() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .denied,
                authorizationRequestExpectedStatus: .success(())
            ),
            notificationRelay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            sharedKeyRepository: MockGuidSharedKeyRepositoryAPI(),
            guidRepository: MockGuidSharedKeyRepositoryAPI()
        )

        let result = service.sendTokenIfNeeded().toBlocking()

        do {
            try result.first()
            XCTFail("expected permission authorization. got success instead")
        } catch {}
    }

    // MARK: - Unauthorized permission

    func testTokenSendWithExternalServiceFetchingFailure() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            notificationRelay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .failure(.init(info: "token fetch failure")),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .success(())),
            sharedKeyRepository: MockGuidSharedKeyRepositoryAPI(),
            guidRepository: MockGuidSharedKeyRepositoryAPI()
        )

        let result = service.sendTokenIfNeeded().toBlocking()

        do {
            try result.first()
            XCTFail("expected failure fetching the token. got success instead")
        } catch {}
    }

    // MARK: - Unauthorized permission

    func testTokenSendWithNetworkServiceFailure() {
        let service: RemoteNotificationTokenSending = RemoteNotificationService(
            authorizer: MockRemoteNotificationAuthorizer(
                expectedAuthorizationStatus: .authorized,
                authorizationRequestExpectedStatus: .success(())
            ),
            notificationRelay: MockRemoteNotificationRelay(),
            externalService: MockExternalNotificationServiceProvider(
                expectedTokenResult: .success("firebase-token-value"),
                expectedTopicSubscriptionResult: .success(())
            ),
            networkService: MockRemoteNotificationNetworkService(expectedResult: .failure(.registrationFailure)),
            sharedKeyRepository: MockGuidSharedKeyRepositoryAPI(),
            guidRepository: MockGuidSharedKeyRepositoryAPI()
        )

        let result = service.sendTokenIfNeeded().toBlocking()

        do {
            try result.first()
            XCTFail("expected failure sending the token. got success instead")
        } catch {}
    }
}
