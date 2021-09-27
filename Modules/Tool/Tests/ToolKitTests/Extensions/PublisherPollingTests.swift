// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit
import XCTest

final class PublisherPollingTests: XCTestCase {

    private class ResultMocker {
        var stubbedResult: Int = 0
    }

    func test_polling_returns_immediately_when_closure_matches() {
        // GIVEN: A publisher that returns the value of a result mocker
        let (publisher, resultMocker) = makePublisher()
        // AND: A mocked result that matches expectations
        resultMocker.stubbedResult = 1

        let e = expectation(description: "Wait for polling operation to end")
        var returnedValue: Int?

        // WHEN: The publisher starts polling
        let cancellable = publisher.startPolling(
            until: { value in value == 1 }
        )
        .sink { value in
            returnedValue = value
            e.fulfill()
        }

        // THEN: The result is sinked immediately
        wait(for: [e], timeout: 5)
        XCTAssertEqual(returnedValue, 1)
        cancellable.cancel()
    }

    func test_polling_retries_until_closure_matches_once() {
        // GIVEN: A publisher that returns the value of a result mocker
        let (publisher, resultMocker) = makePublisher()
        // AND: A mocked result that matches expectations

        let pollValidationExpectation = expectation(description: "Wait for one poll validation check")
        pollValidationExpectation.assertForOverFulfill = false
        let completionExpectation = expectation(description: "Wait for polling operation to end")
        var returnedValue: Int?

        // WHEN: The publisher starts polling
        let cancellable = publisher.startPolling(
            until: { value in
                pollValidationExpectation.fulfill()
                return value == 1
            }
        )
        .sink { value in
            returnedValue = value
            completionExpectation.fulfill()
        }

        // AND: One attempt has been made
        wait(for: [pollValidationExpectation], timeout: 5)
        // AND: A second attempt results in the expected value
        resultMocker.stubbedResult = 1

        // THEN: The result is sinked immediately
        wait(for: [completionExpectation], timeout: 5)
        XCTAssertEqual(returnedValue, 1)
        cancellable.cancel()
    }

    func test_polling_retries_until_timeout() {
        // GIVEN: A publisher that returns the value of a result mocker
        let (publisher, _) = makePublisher()
        // AND: A mocked result that matches expectations

        let pollValidationExpectation = expectation(description: "Wait for one poll validation check")
        pollValidationExpectation.assertForOverFulfill = false
        let completionExpectation = expectation(description: "Wait for polling operation to end")
        var returnedValue: Int?
        var mockDate: Date?

        // WHEN: The publisher starts polling
        let cancellable = publisher.startPolling(
            timeoutInterval: .minutes(5),
            until: { value in
                pollValidationExpectation.fulfill()
                return value == 1
            },
            currentDateFactory: { mockDate ?? Date() }
        )
        .sink { value in
            returnedValue = value
            completionExpectation.fulfill()
        }

        // AND: Attempts have been made
        wait(for: [pollValidationExpectation], timeout: 5)
        // AND: The timeout elapses before the result matches expectations
        mockDate = Date(timeIntervalSinceNow: .minutes(10))

        // THEN: The result is sinked immediately
        wait(for: [completionExpectation], timeout: 5)
        XCTAssertEqual(returnedValue, 0)
        cancellable.cancel()
    }

    private func makePublisher() -> (publisher: AnyPublisher<Int, Never>, resultMocker: ResultMocker) {
        let resultMocker = ResultMocker()
        let publisher: AnyPublisher<Int, Never> = Deferred {
            Future { completion in
                completion(.success(resultMocker.stubbedResult))
            }
        }
        .eraseToAnyPublisher()
        return (publisher, resultMocker)
    }
}
