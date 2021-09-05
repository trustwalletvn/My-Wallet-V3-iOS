// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
@testable import PlatformKitMock
import XCTest

class CustodialBalanceResponseTests: XCTestCase {

    func testDecodable() {
        let result: CustodialBalanceResponse! = CustodialBalanceResponse.mock(json: CustodialBalanceResponse.mockJson)
        XCTAssertNotNil(result, "CustodialBalanceResponse should exist")
        XCTAssertNotNil(result[.crypto(.coin(.ethereum))], "CustodialBalanceResponse.eth should exist")
        XCTAssertNotNil(result[.crypto(.coin(.bitcoin))], "CustodialBalanceResponse.btc should exist")
    }
}
