// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

/// A network client for `GUID`
public final class GuidClient: GuidClientAPI {

    // MARK: - Types

    struct Response: Decodable {
        let guid: String?
    }

    // MARK: - Properties

    private let networkAdpater: NetworkAdapterAPI
    private let requestBuilder: GuidRequestBuilder

    // MARK: - Setup

    public init(
        networkAdpater: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdpater = networkAdpater
        self.requestBuilder = GuidRequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    /// fetches the `GUID`
    public func guid(by sessionToken: String) -> AnyPublisher<String?, NetworkError> {
        let request = requestBuilder.build(sessionToken: sessionToken)
        return networkAdpater
            .perform(request: request, responseType: Response.self)
            .map(\.guid)
            .eraseToAnyPublisher()
    }
}

// MARK: - GuidRequestBuilder

extension GuidClient {

    private struct GuidRequestBuilder {

        private let pathComponents = ["wallet", "poll-for-session-guid"]

        private enum HeaderKey: String {
            case cookie
        }

        private enum Query: String {
            case format
            case resendCode = "resend_code"
        }

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build(sessionToken: String) -> NetworkRequest {
            let headers = [HeaderKey.cookie.rawValue: "SID=\(sessionToken)"]
            let parameters = [
                URLQueryItem(
                    name: Query.format.rawValue,
                    value: "json"
                ),
                URLQueryItem(
                    name: Query.resendCode.rawValue,
                    value: "false"
                )
            ]
            return requestBuilder.get(
                path: pathComponents,
                parameters: parameters,
                headers: headers
            )!
        }
    }
}
