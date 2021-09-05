// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class NabuAnalyticsEventsRepositoryTests: XCTestCase {
    var analyticsEventsRepository: NabuAnalyticsEventsRepository?

    let clientMock = mock(EventSendingAPI.self)
    let tokenRepository = mock(TokenRepositoryAPI.self)

    private var cancellables = Set<AnyCancellable>()

    override func setUpWithError() throws {
        try super.setUpWithError()
        analyticsEventsRepository = NabuAnalyticsEventsRepository(
            client: clientMock,
            tokenRepository: tokenRepository
        )
    }

    override func tearDownWithError() throws {
        analyticsEventsRepository = nil
        try super.tearDownWithError()
    }

    func test_nabuAnalyticsEventsRepository_callsClientWithEventsAndToken() {
        let events = 1
        let token = "token"
        given(tokenRepository.getSessionToken()) ~> token
        given(clientMock.publish(events: events, token: token)) ~> Empty().eraseToAnyPublisher()

        _ = analyticsEventsRepository?.publish(events: events)

        verify(clientMock.publish(events: events, token: token)).wasCalled(exactly(1))
    }
}
