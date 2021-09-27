// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import PlatformKit
@testable import RemoteNotificationsKit
import RxBlocking
import RxSwift
import UserNotifications
import XCTest

final class ExternalNotificationServiceProviderTests: XCTestCase {

    func testSuccessfullTokenFetching() {
        let expectedToken = "fcm-token-value"
        let messagingService = MockMessagingService(expectedTokenResult: .success(expectedToken))
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        do {
            let token = try provider.token.toBlocking().first()!
            XCTAssertEqual(token, expectedToken)
        } catch {
            XCTFail("expected successful token fetch. got \(error) instead")
        }
    }

    func testEmptyTokenFetchingFailure() {
        let messagingService = MockMessagingService(expectedTokenResult: .failure(.tokenIsEmpty))
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        do {
            let token = try provider.token.toBlocking().first()!
            XCTFail("expected \(RemoteNotification.TokenFetchError.tokenIsEmpty). got token \(token) instead")
        } catch RemoteNotification.TokenFetchError.tokenIsEmpty {
            // Okay
        } catch {
            XCTFail("expected \(RemoteNotification.TokenFetchError.tokenIsEmpty). got \(error) instead")
        }
    }

    func testTopicSubscriptionSuccess() {
        let messagingService = MockMessagingService(expectedTokenResult: .success(""), shouldSubscribeToTopicsSuccessfully: true)
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        let topic = RemoteNotification.Topic.todo
        do {
            try provider.subscribe(to: topic).toBlocking().first()
            XCTAssertTrue(messagingService.topics.contains(topic))
        } catch {
            XCTFail("expected successful topic subscription. got \(error) instead")
        }
    }

    func testTopicSubscriptionFailure() {
        let messagingService = MockMessagingService(expectedTokenResult: .failure(.tokenIsEmpty), shouldSubscribeToTopicsSuccessfully: false)
        let provider = ExternalNotificationServiceProvider(messagingService: messagingService)
        let topic = RemoteNotification.Topic.todo
        do {
            try provider.subscribe(to: topic).toBlocking().first()
            XCTFail("expected \(MockMessagingService.FakeError.subscriptionFailure) topic subscription. got success instead")
        } catch MockMessagingService.FakeError.subscriptionFailure {
            // Okay
        } catch {
            XCTFail("expected \(MockMessagingService.FakeError.subscriptionFailure) topic subscription. got \(error) instead")
        }

        XCTAssertFalse(messagingService.topics.contains(topic))
    }
}
