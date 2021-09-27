// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit
import XCTest

class PeriodicCacheRefreshControlTests: XCTestCase {

    // MARK: - Private Properties

    private var subject: PeriodicCacheRefreshControl!

    // MARK: - Setup

    override func setUp() {
        super.setUp()

        subject = PeriodicCacheRefreshControl(refreshInterval: 10)
    }

    override func tearDown() {
        subject = nil

        super.tearDown()
    }

    func testShouldRefreshOldValue() {
        // GIVEN: an old last refresh
        let oldLastRefresh = Date(timeIntervalSinceNow: -20)

        // WHEN: checking if the values should be refreshed
        let shouldRefresh = subject.shouldRefresh(lastRefresh: oldLastRefresh)

        // THEN: the return value is `true`
        XCTAssertTrue(shouldRefresh)
    }

    func testShouldNotRefreshRecentValue() {
        // GIVEN: a recent last refresh
        let recentLastRefresh = Date(timeIntervalSinceNow: -5)

        // WHEN: checking if the value should be refreshed
        let shouldRefresh = subject.shouldRefresh(lastRefresh: recentLastRefresh)

        // THEN: the return value is `false`
        XCTAssertFalse(shouldRefresh)
    }
}
