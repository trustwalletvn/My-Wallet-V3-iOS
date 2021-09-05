// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import XCTest

@testable import AnalyticsKit

final class RequestTests: XCTestCase {

    func test_request_mappingToUrlRequest() throws {
        let url = URL(string: "https://api.blockchain.info/")!
        let data = Data(base64Encoded: "eyJ0ZXN0IjoxfQ==")
        let headers = ["TestHeader": "Value"]
        let request = Request(method: .post, url: url, body: data, headers: headers)

        let urlRequest = request.asURLRequest()

        XCTAssertEqual(urlRequest.allHTTPHeaderFields, headers)
        XCTAssertEqual(urlRequest.httpMethod, "POST")
        XCTAssertEqual(urlRequest.httpBody, data)
        XCTAssertEqual(urlRequest.url, url)
    }
}
