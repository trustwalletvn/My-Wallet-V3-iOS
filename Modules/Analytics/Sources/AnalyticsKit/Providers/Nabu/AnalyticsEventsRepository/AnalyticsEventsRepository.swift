// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

protocol NabuAnalyticsEventsRepositoryAPI {
    func publish<Events: Encodable>(
        events: Events
    ) -> AnyPublisher<Never, URLError>
}

final class NabuAnalyticsEventsRepository: NabuAnalyticsEventsRepositoryAPI {

    // MARK: - Private properties

    private let client: EventSendingAPI
    private let tokenRepository: TokenRepositoryAPI

    // MARK: - Setup

    init(
        client: EventSendingAPI,
        tokenRepository: TokenRepositoryAPI
    ) {
        self.client = client
        self.tokenRepository = tokenRepository
    }

    // MARK: - AnalyticsEventsRepositoryAPI

    func publish<Events: Encodable>(
        events: Events
    ) -> AnyPublisher<Never, URLError> {
        client.publish(events: events, token: tokenRepository.sessionToken)
            .eraseToAnyPublisher()
    }
}
