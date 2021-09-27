// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

/// A client in charge of interacting with the ethereum backend service, in order to fetch ERC-20 data.
///
/// - Note: The `New` suffix should be removed after `ERC20DataKit` data layer migration has been completed.
protocol ERC20AccountClientAPINew {

    /// Fetches the ERC-20 token accounts associated with the given ethereum account address.
    ///
    /// - Parameter address: The ethereum account address to fetch the ERC-20 token accounts for.
    ///
    /// - Returns: A publisher that emits a `ERC20TokenAccountsReponse` on success, or a `NetworkError` on failure.
    func tokens(for address: String) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError>
}

/// The client in charge of interacting with the ethereum backend service, in order to fetch ERC-20 data.
final class ERC20AccountClient: ERC20AccountClientAPINew {

    // MARK: - Private Types

    /// URL path and query constructors for V2 endpoints (`eth/v2`).
    private enum EndpointV2 {

        private static let base: [String] = ["eth", "v2"]

        /// The URL path for a given account (e.g. `eth/v2/account/<address>`).
        ///
        /// - Parameter address: An ethereum account address.
        static func account(for address: String) -> [String] {
            base + ["account", address]
        }

        /// The URL path to the `tokens` endpoint, for a given account (e.g. `eth/v2/account/<address>/tokens`).
        ///
        /// - Parameter address: An ethereum account address.
        static func tokens(for address: String) -> [String] {
            account(for: address) + ["tokens"]
        }
    }

    // MARK: - Private Properties

    private let networkAdapter: NetworkAdapterAPI

    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    /// Creates an ERC-20 account client.
    ///
    /// - Parameters:
    ///   - networkAdapter: A network adapter.
    ///   - requestBuilder: A request builder.
    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve()
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - Internal Methods

    func tokens(for address: String) -> AnyPublisher<ERC20TokenAccountsResponse, NetworkError> {
        let path = EndpointV2.tokens(for: address)
        let request = requestBuilder.get(path: path)!
        return networkAdapter.perform(request: request)
    }
}
