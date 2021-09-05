// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

public protocol UserCreationClientAPI: AnyObject {

    func createUser(for jwtToken: String) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError>
}

final class UserCreationClient: UserCreationClientAPI {

    // MARK: - Types

    private enum Parameter: String {
        case jwt
    }

    private enum Path {
        static let users = ["users"]
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

    func createUser(for jwtToken: String) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError> {
        struct Payload: Encodable {
            let jwt: String
        }
        let payload = Payload(jwt: jwtToken)
        let request = requestBuilder.post(
            path: Path.users,
            body: try? payload.encode()
        )!
        return networkAdapter.perform(request: request)
    }
}
