// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import XCTest

final class SupportedAssetsFilePathProviderTests: XCTestCase {

    var sut: SupportedAssetsFilePathProviderAPI!

    override func setUp() {
        super.setUp()
        sut = SupportedAssetsFilePathProvider()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testLocalERC20FileIsNotPresent() {
        XCTAssertNil(sut.localERC20Assets)
    }

    func testLocalCustodialFileIsPresent() {
        guard let localFile = sut.localCustodialAssets else {
            XCTFail("Missing local file.")
            return
        }
        XCTAssertTrue(localFile.absoluteString.contains("local-currencies-custodial.json"))
        XCTAssertTrue(FileManager.default.fileExists(atPath: localFile.relativePath))
    }
}
