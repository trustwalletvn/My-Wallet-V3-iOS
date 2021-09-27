// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
@testable import StellarKit
import XCTest

class StellarCryptoReceiveAddressFactoryTests: XCTestCase {

    var sut: CryptoReceiveAddressFactory!
    var address: CryptoReceiveAddress!

    override func setUp() {
        super.setUp()
        sut = StellarCryptoReceiveAddressFactory()
    }

    override func tearDown() {
        sut = nil
        address = nil
    }

    func testInvalidAddress() throws {
        XCTAssertThrowsError(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: "1234567890",
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )
    }

    func testAddressOnly() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.address,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, nil)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testAddressColonMemo() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.addressColonMemo,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testAddressColonMemoWithEqualLabel() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.addressColonMemo,
                    label: StellarTestData.addressColonMemo,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.addressColonMemo)
    }

    func testURLAddress() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.urlString,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, nil)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoWithEqualLabel() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.urlStringWithMemo,
                    label: StellarTestData.urlStringWithMemo,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.urlStringWithMemo)
    }

    func testURLAddressWithMemo() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.urlStringWithMemo,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoAndType() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.urlStringWithMemoType,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }

    func testURLAddressWithMemoAndAmount() throws {
        XCTAssertNoThrow(
            address = try sut
                .makeExternalAssetAddress(
                    asset: .coin(.stellar),
                    address: StellarTestData.urlStringWithMemoAndAmount,
                    label: StellarTestData.label,
                    onTxCompleted: { _ in .empty() }
                )
                .get()
        )

        XCTAssertEqual(address.address, StellarTestData.address)
        XCTAssertEqual(address.memo, StellarTestData.memo)
        XCTAssertEqual(address.label, StellarTestData.label)
    }
}
