// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation

public class RequestBuilder {

    public enum Error: Swift.Error {
        case buildingRequest
    }

    private var defaultComponents: URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = networkConfig.apiScheme
        urlComponents.host = networkConfig.apiHost
        urlComponents.path = RequestBuilder.path(from: networkConfig.pathComponents)
        return urlComponents
    }

    private let networkConfig: Network.Config

    init(networkConfig: Network.Config = resolve()) {
        self.networkConfig = networkConfig
    }

    // MARK: - GET

    public func get(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        get(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func get(
        path: String,
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .get,
            path: path,
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - PUT

    public func put(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        put(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func put(
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .put,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - POST

    public func post(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        post(
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    public func post(
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .post,
            path: path,
            parameters: parameters,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Delete

    public func delete(
        path components: [String] = [],
        parameters: [URLQueryItem]? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        buildRequest(
            method: .delete,
            path: RequestBuilder.path(from: components),
            parameters: parameters,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    // MARK: - Utilities

    public static func body(from parameters: [URLQueryItem]) -> Data? {
        var components = URLComponents()
        components.queryItems = parameters
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.percentEncodedQuery?.data(using: .utf8)
    }

    // MARK: - Private methods

    private static func path(from components: [String] = []) -> String {
        components.reduce(into: "") { path, component in
            path += "/\(component)"
        }
    }

    private func buildRequest(
        method: NetworkRequest.NetworkMethod,
        path: String,
        parameters: [URLQueryItem]? = nil,
        body: Data? = nil,
        headers: HTTPHeaders = [:],
        authenticated: Bool = false,
        contentType: NetworkRequest.ContentType = .json,
        decoder: NetworkResponseDecoderAPI = resolve(),
        recordErrors: Bool = false
    ) -> NetworkRequest? {
        guard let url = buildURL(path: path, parameters: parameters) else {
            return nil
        }
        return NetworkRequest(
            endpoint: url,
            method: method,
            body: body,
            headers: headers,
            authenticated: authenticated,
            contentType: contentType,
            decoder: decoder,
            recordErrors: recordErrors
        )
    }

    private func buildURL(path: String, parameters: [URLQueryItem]? = nil) -> URL? {
        var components = defaultComponents
        components.path += path
        if let parameters = parameters {
            components.queryItems = parameters
        }
        return components.url
    }
}
