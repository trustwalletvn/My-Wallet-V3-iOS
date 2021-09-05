// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Foundation
import NetworkKit

public final class AutoWalletPairingClient: AutoWalletPairingClientAPI {

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: AutoWalletPairingClientRequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.wallet),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = AutoWalletPairingClientRequestBuilder(requestBuilder: requestBuilder)
    }

    // MARK: - API

    public func request(guid: String) -> AnyPublisher<String, NetworkError> {
        let request = requestBuilder.build(guid: guid)
        return networkAdapter
            .perform(request: request, responseType: RawServerResponse.self)
            .map(\.data)
            .eraseToAnyPublisher()
    }
}

// MARK: - Request Builder

extension AutoWalletPairingClient {

    private struct AutoWalletPairingClientRequestBuilder {

        // MARK: - Types

        private let pathComponents = ["wallet"]

        private enum Parameters {
            static let guid = "guid"
            static let method = "method"
        }

        // MARK: - Builder

        private let requestBuilder: RequestBuilder

        // MARK: - Setup

        init(requestBuilder: RequestBuilder) {
            self.requestBuilder = requestBuilder
        }

        // MARK: - API

        func build(guid: String) -> NetworkRequest {
            let parameters = [
                URLQueryItem(
                    name: Parameters.guid,
                    value: guid
                ),
                URLQueryItem(
                    name: Parameters.method,
                    value: "pairing-encryption-password"
                )
            ]
            let data = RequestBuilder.body(from: parameters)
            return requestBuilder.post(
                path: pathComponents,
                body: data,
                contentType: .formUrlEncoded
            )!
        }
    }
}
