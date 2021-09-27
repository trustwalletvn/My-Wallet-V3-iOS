// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

@testable import RemoteNotificationsKit

/// A class that is a gateway to external notification service functionality
final class MockExternalNotificationServiceProvider: ExternalNotificationProviding {

    struct FakeError: Error {
        let info: String
    }

    var token: Single<String> {
        expectedTokenResult.single
    }

    private let expectedTokenResult: Result<String, FakeError>
    private let expectedTopicSubscriptionResult: Result<Void, FakeError>

    private(set) var topics: [RemoteNotification.Topic] = []

    init(
        expectedTokenResult: Result<String, FakeError>,
        expectedTopicSubscriptionResult: Result<Void, FakeError>
    ) {
        self.expectedTokenResult = expectedTokenResult
        self.expectedTopicSubscriptionResult = expectedTopicSubscriptionResult
    }

    func didReceiveNewApnsToken(token: Data) {}

    func subscribe(to topic: RemoteNotification.Topic) -> Single<Void> {
        switch expectedTopicSubscriptionResult {
        case .success:
            topics.append(topic)
        case .failure:
            break
        }
        return expectedTopicSubscriptionResult.single
    }
}
