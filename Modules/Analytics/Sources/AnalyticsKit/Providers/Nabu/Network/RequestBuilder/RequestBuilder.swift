// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

protocol RequestBuilderAPI {
    func post(path: String, body: Data?, headers: [String: String]) -> Request
}

class RequestBuilder: RequestBuilderAPI {
    private let basePath: String
    private let userAgent: String

    init(basePath: String, userAgent: String) {
        self.basePath = basePath
        self.userAgent = userAgent
    }

    func post(path: String, body: Data?, headers: [String: String]) -> Request {
        var headers = headers
        headers["User-Agent"] = userAgent
        return Request(method: .post, url: URL(string: basePath + path)!, body: body, headers: headers)
    }
}
