// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import XCTest

extension XCTestCase {

    @discardableResult
    public func wait<Output, Error>(
        for publisher: AnyPublisher<Output, Error>,
        file: StaticString = #file,
        line: UInt = #line
    ) -> Result<Output, Error>? {
        let e = expectation(description: "Waiting for publisher to complete")
        var value: Output?, error: Error?
        let cancellable = publisher.sink { result in
            switch result {
            case .failure(let theError):
                error = theError
            case .finished:
                e.fulfill()
            }
        } receiveValue: { theValue in
            value = theValue
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()

        if let value = value {
            return .success(value)
        } else if let error = error {
            return .failure(error)
        }
        return nil
    }
}
