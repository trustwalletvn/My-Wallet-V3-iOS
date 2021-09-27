// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import BitcoinChainKit
import PlatformKit
import XCTest

class BitcoinURLPayloadTests: XCTestCase {

    func testInvalidScheme() {
        let url = URL(string: "somescheme")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNil(payload)
    }

    func testEmptyURI() {
        let url = URL(string: "\(BitcoinURLPayload.scheme)://")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNil(payload)
    }

    func testBitcoinWebFormat() {
        let address = "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv"
        let url = URL(string: "\(BitcoinURLPayload.scheme):\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinWebFormatWithAmount() {
        let address = "1Amu4uPJnYbUXX2HhDFMNq7tSneDwWYDyv"
        let amount = "1.03"
        let url = URL(string: "\(BitcoinURLPayload.scheme):\(address)?amount=\(amount)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
        XCTAssertEqual(amount, payload!.amount)
    }

    func testBitcoinAddressInHost() {
        let address = "bitcoinaddress"
        let url = URL(string: "\(BitcoinURLPayload.scheme)://\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinAddressInQueryArg() {
        let address = "bitcoinaddress"
        let url = URL(string: "\(BitcoinURLPayload.scheme)://?address=\(address)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
    }

    func testBitcoinAddressAndAmount() {
        let address = "bitcoinaddress"
        let amount = "1.03"
        let url = URL(string: "\(BitcoinURLPayload.scheme)://\(address)?amount=\(amount)")
        let payload = BitcoinURLPayload(url: url!)
        XCTAssertNotNil(payload)
        XCTAssertEqual(address, payload!.address)
        XCTAssertEqual(amount, payload!.amount)
    }

    func testBitcoinPaymentRequestUrl() {
        let url = URL(string: "bitcoin://?r=https://bitpay.com/i/7pZrguiGf21Y73rPN8J3s5")!
        let payload = BitcoinURLPayload(url: url)
        XCTAssertNil(payload)
    }
}
