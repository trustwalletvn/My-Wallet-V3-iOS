// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import NetworkKit

/// A session token client implementation
public final class SessionTokenClient: SessionTokenClientAPI {

    // MARK: - Types

    private enum Path {
        static let walletSession = ["wallet", "sessions"]
    }

    private struct Response: Decodable {
        let token: String?
    }

    // MARK: - Properties

    /// Requests a session token for the wallet, if not available already
    public var token: AnyPublisher<String?, NetworkError> {
        let request = requestBuilder.post(
            path: Path.walletSession
        )!
        return networkAdapter
            .perform(request: request, responseType: Response.self)
            .map(\.token)
            .eraseToAnyPublisher()
    }

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    public init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.wallet)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }
}
