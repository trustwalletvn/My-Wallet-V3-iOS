// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import XCTest

class EthereumPushTxResponseTests: XCTestCase {

    func testDecoding() {
        let response = try? JSONDecoder().decode(EthereumPushTxResponse.self, from: fixture)
        XCTAssertNotNil(response)
        XCTAssertEqual(response?.txHash, "0x3a69218edf483724d398223eab78fa4de66df7aa737f137f2914fc371506af90")
    }

    private let fixture = Data("""
    {
        "txHash" : "0x3a69218edf483724d398223eab78fa4de66df7aa737f137f2914fc371506af90"
    }
    """.utf8)
}
