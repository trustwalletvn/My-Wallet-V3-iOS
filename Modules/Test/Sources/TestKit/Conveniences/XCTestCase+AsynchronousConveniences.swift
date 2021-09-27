// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import XCTest

extension XCTestCase {

    /// Wait on a group of expectations for up to the specified timeout.
    ///
    /// May return early based on fulfillment of the waited on expectations.
    ///
    /// - Parameters:
    ///   - expectations: The expectations to wait for.
    ///   - seconds:      The amount of time within which all expectations must be fulfilled.
    ///   - file:         The file where the failure occurs. The default is the filename of the test case where you call this function.
    ///   - line:         The line number where the failure occurs. The default is the line number where you call this function.
    public func wait(
        for expectations: [XCTestExpectation],
        timeout seconds: TimeInterval,
        file: StaticString = #file,
        line: UInt = #line
    ) {
        let result = XCTWaiter().wait(for: expectations, timeout: seconds)

        switch result {
        case .completed:
            break
        case .incorrectOrder:
            XCTFail("Failed due to expectation fulfilled in incorrect order", file: file, line: line)
        case .interrupted:
            XCTFail("Asynchronous waiter failed - Interrupted by timeout of containing waiter", file: file, line: line)
        case .invertedFulfillment:
            XCTFail("Asynchronous wait failed - Fulfilled inverted expectation", file: file, line: line)
        case .timedOut:
            XCTFail(
                "Asynchronous wait failed - Exceeded timeout of \(seconds) seconds, with unfulfilled expectations",
                file: file,
                line: line
            )
        @unknown default:
            fatalError("Unhandled case from XCTWaiter.Result: \(result).")
        }
    }
}
