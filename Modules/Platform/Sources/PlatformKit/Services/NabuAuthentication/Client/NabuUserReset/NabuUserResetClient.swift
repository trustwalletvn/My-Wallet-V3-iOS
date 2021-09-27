// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public protocol NabuResetUserClientAPI: AnyObject {

    func resetUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String
    ) -> AnyPublisher<Void, NetworkError>
}

final class NabuResetUserClient: NabuResetUserClientAPI {

    // MARK: - Type

    private enum Path {
        static func reset(userId: String) -> [String] {
            ["users", "reset", userId]
        }
    }

    // MARK: - Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func resetUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String
    ) -> AnyPublisher<Void, NetworkError> {
        let request = requestBuilder.post(
            path: Path.reset(userId: offlineToken.userId),
            body: try? JWTPayload(jwt: jwt).encode(),
            headers: [HttpHeaderField.authorization: "Bearer \(offlineToken.token)"]
        )!
        return networkAdapter
            .perform(
                request: request,
                responseType: EmptyNetworkResponse.self
            )
            .mapToVoid()
    }
}
