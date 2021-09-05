// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxBlocking
import RxRelay
import RxSwift
import RxTest
import XCTest

@testable import ToolKit

final class CachedValueTests: XCTestCase {

    private var disposeBag = DisposeBag()
    private var testScheduler: TestScheduler!

    override func setUp() {
        testScheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    func testInitialSubscriptionToValue() {
        let expectedValue = "expected_value"
        let configuration = CachedValueConfiguration(refreshType: .onSubscription)
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch { Single.just(expectedValue) }
        do {
            let value = try cachedValue.valueSingle.toBlocking().first()
            XCTAssertEqual(value, expectedValue)
        } catch {
            XCTFail(String(describing: error))
        }
    }

    func testMultipleConsecutiveFetches() {
        let expectedResults: [String] = ["expected_result1", "expected_result2", "expected_result3"]
        var index = 0

        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)
        cachedValue.setFetch { () -> Single<String> in
            let current = expectedResults[index % expectedResults.count]
            index += 1
            return Single.just(current)
        }

        for index in 0...7 {
            XCTAssertEqual(
                try? cachedValue.fetchValue.toBlocking().first(),
                expectedResults[index % expectedResults.count]
            )
        }
    }

    func testsRefreshTypeOnce() {
        let expectedResult = "expected_result1"

        let configuration = CachedValueConfiguration(
            refreshType: .onSubscription
        )
        let cachedValue = CachedValue<String>(configuration: configuration)

        cachedValue.setFetch {
            Single.just(expectedResult)
        }

        for _ in 0...7 {
            XCTAssertEqual(
                try? cachedValue.valueSingle.toBlocking().first(),
                expectedResult
            )
        }
    }
}
