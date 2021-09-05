// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import XCTest

class DeepLinkRouteTests: XCTestCase {

    func testAirdropUrl() {
        let url = "https://login.blockchain.com/#/open/referral?campaign=sunriver"
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNotNil(route)
        XCTAssertEqual(DeepLinkRoute.xlmAirdop, route)
    }

    func testAirdropUrlWithExtraParams() {
        let url = "https://login.blockchain.com/#/open/referral?campaign=sunriver&something=else"
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNotNil(route)
        XCTAssertEqual(DeepLinkRoute.xlmAirdop, route)
    }

    func testInvalidPath() {
        let url = "https://login.blockchain.com/#/open/notasupportedurl"
        let route = DeepLinkRoute.route(from: url)
        XCTAssertNil(route)
    }
}
