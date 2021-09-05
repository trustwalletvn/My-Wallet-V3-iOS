// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import Mockingbird
import XCTest

@testable import AnalyticsKit

final class RequestBuilderTests: XCTestCase {

    var requestBuilder: RequestBuilder?

    override func setUpWithError() throws {
        try super.setUpWithError()
        requestBuilder = RequestBuilder(basePath: "https://api.blockchain.info/", userAgent: "iOS")
    }

    override func tearDownWithError() throws {
        requestBuilder = nil
        try super.tearDownWithError()
    }

    func test_requestBuilder_buildsValidRequest() throws {
        let body = Data(base64Encoded: "dGVzdA==")
        let request = requestBuilder?.post(path: "path/test", body: body, headers: ["Test": "Value"])
        XCTAssertEqual(request?.method, .post)
        XCTAssertEqual(request?.body, body)
        XCTAssertEqual(request?.url.absoluteString, "https://api.blockchain.info/path/test")
        XCTAssertEqual(request?.headers, ["User-Agent": "iOS", "Test": "Value"])
    }
}
