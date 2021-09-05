// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct Request {
    enum HTTPMethod: String {
        case post = "POST"
    }

    let method: HTTPMethod
    let url: URL
    let body: Data?
    let headers: [String: String]

    func asURLRequest() -> URLRequest {
        var urlRequest = URLRequest(url: url)
        urlRequest.httpBody = body
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}
