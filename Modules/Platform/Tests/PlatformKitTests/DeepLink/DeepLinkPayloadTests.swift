// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import XCTest

class DeepLinkPayloadTests: XCTestCase {
    func testAirdropPayloadWithParams() {
        let url = "https://login.blockchain.com/#/open/referral?campaign=sunriver&campaign_code=asdf-1234-efgh"
        let payload = DeepLinkPayload.create(from: url, supportedRoutes: DeepLinkRoute.allCases)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload!.params["campaign_code"], "asdf-1234-efgh")
    }

    func testAirdropPayloadDecode() {
        let url = "https://login.blockchain.com/#/open/referral?campaign=sunriver&campaign_email=email%2Bhi%40blah.com"
        let payload = DeepLinkPayload.create(from: url, supportedRoutes: DeepLinkRoute.allCases)
        XCTAssertNotNil(payload)
        XCTAssertEqual(payload!.params["campaign_email"], "email+hi@blah.com")
    }
}
