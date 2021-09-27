// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import TestKit
import ToolKit
import XCTest

class AtomicTests: XCTestCase {

    // MARK: - Private Properties

    private let iterations = 100000

    private var subject: Atomic<Int>!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        subject = Atomic(0)
    }

    override func tearDown() {
        subject = nil

        super.tearDown()
    }

    // MARK: - Read

    func test_read_concurrent() {
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            XCTAssertEqual(subject.value, 0)
        }
    }

    func test_read_performance() {
        measure {
            for _ in 0..<iterations {
                _ = subject!.value
            }
        }
    }

    // MARK: - Write

    func test_write_concurrent() {
        DispatchQueue.concurrentPerform(iterations: iterations) { _ in
            subject.mutate { $0 += 1 }
        }

        XCTAssertEqual(subject.value, iterations)
    }

    func test_write_performance() {
        measure {
            for _ in 0..<iterations {
                subject.mutate { $0 += 1 }
            }
        }
    }

    // MARK: - Read and Write

    func test_readAndWrite_concurrent() {
        DispatchQueue.concurrentPerform(iterations: iterations) { i in
            _ = subject!.value

            if i.isMultiple(of: 1000) {
                subject.mutate { $0 += 1 }
            }
        }

        XCTAssertEqual(subject.value, iterations / 1000)
    }

    func test_readAndWrite_performance() {
        measure {
            for i in 0..<iterations {
                _ = subject!.value

                if i.isMultiple(of: 1000) {
                    subject.mutate { $0 += 1 }
                }
            }
        }
    }

    // MARK: - Publisher

    func test_publisher_updates() {
        // GIVEN: an initial value of 0
        let newValues = Array(1...1000)
        // Also streams the initial value.
        let expectedValues = [0] + newValues

        // WHEN: updating the atomic multiple times
        let publisher = subject!.publisher

        let assertion = XCTAsyncAssertPublisherValues(publisher, expectedValues, expectCompletion: false)

        for newValue in newValues {
            subject.mutate { $0 = newValue }
        }

        // THEN: all the updates are collected
        assertion()
    }

    func test_publisher_updatesConcurrent() {
        // GIVEN: an initial value of 0
        let newValues = Array(1...1000)
        // Also streams the initial value.
        let expectedValues = [0] + newValues

        // WHEN: updating the atomic multiple times on multiple threads
        let publisher = subject!.publisher

        let assertion = XCTAsyncAssertPublisherValues(
            publisher,
            expectedValues,
            transformReceived: { $0.sort() },
            expectCompletion: false
        )

        DispatchQueue.concurrentPerform(iterations: newValues.count) { i in
            subject.mutate { $0 = newValues[i] }
        }

        // THEN: all the updates are collected
        assertion()
    }
}
