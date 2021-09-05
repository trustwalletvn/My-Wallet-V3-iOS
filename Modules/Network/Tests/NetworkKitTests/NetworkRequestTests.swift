// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import NetworkKit
import XCTest

final class NetworkRequestTests: XCTestCase {

    // MARK: - CustomStringConvertible

    func test_get_request_description_unauthenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .get).with(authenticated: false).build()
        print("TTT \(request.description)")
        XCTAssertEqual(request.description, "GET https://blockchain.com (unauthenticated)")
    }

    func test_get_request_description_authenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .get).with(authenticated: true).build()
        XCTAssertEqual(request.description, "GET https://blockchain.com (authenticated)")
    }

    func test_post_request_description_unauthenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .post).with(authenticated: false).build()
        XCTAssertEqual(request.description, "POST https://blockchain.com (unauthenticated)")
    }

    func test_post_request_description_authenticated() throws {
        let request = NetworkRequest.MockBuilder().with(method: .post).with(authenticated: true).build()
        XCTAssertEqual(request.description, "POST https://blockchain.com (authenticated)")
    }

    func test_post_request_body_description() throws {
        let parameters = [
            URLQueryItem(name: "TestParamterOne", value: "1"),
            URLQueryItem(name: "TestParameterTwo", value: "2")
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = NetworkRequest.MockBuilder().with(method: .post).with(body: data!).build()
        XCTAssertEqual(request.bodyDescription, "TestParamterOne=1&TestParameterTwo=2")
    }

    func test_post_request_body_description_with_percent_encoding() throws {
        let parameters = [
            URLQueryItem(name: "email", value: "email+test@blockchain.com")
        ]
        let data = RequestBuilder.body(from: parameters)
        let request = NetworkRequest.MockBuilder().with(method: .post).with(body: data!).build()
        XCTAssertEqual(request.bodyDescription, "email=email%2Btest@blockchain.com")
    }
}
