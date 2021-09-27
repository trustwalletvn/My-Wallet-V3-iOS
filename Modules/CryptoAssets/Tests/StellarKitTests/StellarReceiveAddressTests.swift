// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import StellarKit
import XCTest

class StellarReceiveAddressTests: XCTestCase {

    func testStellarReceiveAddressAbsoluteURLIsCorrect() throws {
        let address = StellarReceiveAddress(address: StellarTestData.address, label: StellarTestData.label, memo: StellarTestData.memo)
        XCTAssertEqual(address.metadata.absoluteString, StellarTestData.urlStringWithMemo)
    }

    func testStellarURLPayloadWithMemoTypeText() throws {
        let url = URL(string: StellarTestData.urlStringWithMemoType)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, StellarTestData.urlStringWithMemo)
    }

    func testStellarURLPayloadWithoutMemoType() throws {
        let url = URL(string: StellarTestData.urlStringWithMemo)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, StellarTestData.urlStringWithMemo)
    }

    func testStellarURLPayloadWithMemoTypeTextAmount() throws {
        let url = URL(string: StellarTestData.urlStringWithMemoAndAmount)!
        let address = StellarURLPayload(url: url)
        XCTAssertEqual(address?.absoluteString, StellarTestData.urlStringWithMemoAndAmount)
    }
}
