// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine

class MockURIHandler: URIHandlingAPI {
    var passthroughSubject = PassthroughSubject<DeeplinkOutcome, AppDeeplinkError>()
    var canHandle = false

    var canHandleCalled = false

    func canHandle(url: URL) -> Bool {
        canHandleCalled = true
        return canHandle
    }

    var handleCalled = false

    func handle(url: URL) -> AnyPublisher<DeeplinkOutcome, AppDeeplinkError> {
        handleCalled = true
        return passthroughSubject.eraseToAnyPublisher()
    }
}
