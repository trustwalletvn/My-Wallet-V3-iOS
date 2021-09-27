// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import RxSwift

public typealias HTTPHeaders = [String: String]

public struct NetworkRequest {

    public enum NetworkMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
        case patch = "PATCH"
    }

    public enum ContentType: String {
        case json = "application/json"
        case formUrlEncoded = "application/x-www-form-urlencoded"
    }

    var urlRequest: URLRequest {
        if authenticated, headers[HttpHeaderField.authorization] == nil {
            fatalError("Missing Autentication Header")
        }

        let request = NSMutableURLRequest(
            url: endpoint,
            cachePolicy: allowsCachingResponse ? .useProtocolCachePolicy : .reloadIgnoringLocalCacheData,
            timeoutInterval: timeoutInterval
        )

        request.httpMethod = method.rawValue
        let requestHeaders = headers.merging(defaultHeaders)
        for (key, value) in requestHeaders {
            request.addValue(value, forHTTPHeaderField: key)
        }

        if request.value(forHTTPHeaderField: HttpHeaderField.accept) == nil {
            request.addValue(
                HttpHeaderValue.json,
                forHTTPHeaderField: HttpHeaderField.accept
            )
        }
        if request.value(forHTTPHeaderField: HttpHeaderField.contentType) == nil {
            request.addValue(
                contentType.rawValue,
                forHTTPHeaderField: HttpHeaderField.contentType
            )
        }

        addHttpBody(to: request)

        return request.copy() as! URLRequest
    }

    let method: NetworkMethod
    let endpoint: URL
    private(set) var headers: HTTPHeaders
    let contentType: ContentType
    let decoder: NetworkResponseDecoderAPI
    let responseHandler: NetworkResponseHandlerAPI

    /// Defaults to `true` for `GET` requests
    public var allowsCachingResponse: Bool

    public var timeoutInterval: TimeInterval = 30

    // TODO: modify this to be an Encodable type so that JSON serialization is done in this class
    // vs. having to serialize outside of this class
    let body: Data?

    let recordErrors: Bool

    let authenticated: Bool

    let requestId = UUID()

    private(set) var isDebugging = (
        request: ProcessInfo.processInfo.environment["BLOCKCHAIN_DEBUG_NETWORK_REQUEST"] == "TRUE",
        response: ProcessInfo.processInfo.environment["BLOCKCHAIN_DEBUG_NETWORK_RESPONSE"] == "TRUE"
    )

    private var defaultHeaders: HTTPHeaders {
        [HttpHeaderField.requestId: requestId.uuidString]
    }

    public init(
        endpoint: URL,
        method: NetworkMethod,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        responseHandler: NetworkResponseHandlerAPI = resolve(),
        recordErrors: Bool = false
    ) {
        self.endpoint = endpoint
        self.method = method
        self.body = body
        self.headers = headers
        self.authenticated = authenticated
        self.contentType = contentType
        self.decoder = decoder
        self.responseHandler = responseHandler
        self.recordErrors = recordErrors
        allowsCachingResponse = method == .get
    }

    func adding(authenticationToken: String) -> Self {
        var request = self
        request.headers[HttpHeaderField.authorization] = authenticationToken
        return request
    }

    /// Used by the handler to print debug detailed information about the request and response
    public func debug() -> Self {
        var request = self
        request.isDebugging = (request: true, response: true)
        return request
    }

    private func addHttpBody(to request: NSMutableURLRequest) {
        guard let data = body else {
            return
        }

        switch contentType {
        case .json:
            request.httpBody = data
        case .formUrlEncoded:
            if let params = try? JSONDecoder().decode([String: String].self, from: data) {
                request.encode(params: params)
            } else {
                request.httpBody = data
            }
        }
    }
}

extension NetworkRequest: CustomStringConvertible {

    public var description: String {
        "\(method.rawValue) \(endpoint) (\(authenticated ? "authenticated" : "unauthenticated"))"
    }

    public var bodyDescription: String? {
        guard let data = body,
              let description = String(data: data, encoding: .utf8)
        else {
            return nil
        }
        return description
    }
}

extension NetworkRequest: Hashable {

    public static func == (lhs: NetworkRequest, rhs: NetworkRequest) -> Bool {
        // NOTE: Can't compare urlRequests directly because each request's headers object contains a unique ID T_T
        lhs.endpoint == rhs.endpoint && lhs.method == rhs.method && lhs.body == rhs.body
    }

    public func hash(into hasher: inout Hasher) {
        // NOTE: Can't hash urlRequests directly because each request's headers object contains a unique ID T_T
        hasher.combine(endpoint)
        hasher.combine(method)
        hasher.combine(body)
    }
}

extension NSMutableURLRequest {

    public func encode(params: [String: String]) {
        let encodedParamsArray = params.map { keyPair -> String in
            let (key, value) = keyPair
            return "\(key)=\(self.percentEscapeString(value))"
        }
        httpBody = encodedParamsArray.joined(separator: "&").data(using: .utf8)
    }

    private func percentEscapeString(_ stringToEscape: String) -> String {
        let characterSet = NSMutableCharacterSet.alphanumeric()
        characterSet.addCharacters(in: "-._* ")
        return stringToEscape
            .addingPercentEncoding(withAllowedCharacters: characterSet as CharacterSet)?
            .replacingOccurrences(of: " ", with: "+", options: [], range: nil) ?? stringToEscape
    }
}
