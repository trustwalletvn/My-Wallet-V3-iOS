// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

public final class GuidService: GuidServiceAPI {

    // MARK: - Properties

    /// Fetches the `GUID`
    public var guid: AnyPublisher<String, GuidServiceError> {
        sessionTokenRepository
            .sessionTokenPublisher
            .flatMap { [client] token -> AnyPublisher<String?, GuidServiceError> in
                guard let token = token else {
                    return .failure(.missingSessionToken)
                }
                return client.guid(by: token)
                    .mapError(GuidServiceError.networkError)
                    .eraseToAnyPublisher()
            }
            .flatMap { guidOrNil -> AnyPublisher<String, GuidServiceError> in
                guard let guid = guidOrNil else {
                    return .failure(.missingGuid)
                }
                return .just(guid)
            }
            .eraseToAnyPublisher()
    }

    private let sessionTokenRepository: SessionTokenRepositoryAPI
    private let client: GuidClientAPI

    // MARK: - Setup

    public init(
        sessionTokenRepository: SessionTokenRepositoryAPI,
        client: GuidClientAPI
    ) {
        self.sessionTokenRepository = sessionTokenRepository
        self.client = client
    }
}
