// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import ToolKit

public enum JWTServiceError: Error {
    case failedToRetrieveCredentials(MissingCredentialsError)
    case failedToRetrieveJWTToken
}

public protocol JWTServiceAPI: AnyObject {

    var token: AnyPublisher<String, JWTServiceError> { get }
}

final class JWTService: JWTServiceAPI {

    var token: AnyPublisher<String, JWTServiceError> {
        let client = self.client
        return credentialsRepository
            .credentialsPublisher
            .mapError(JWTServiceError.failedToRetrieveCredentials)
            .flatMap { [client] guid, sharedKey -> AnyPublisher<String, JWTServiceError> in
                client
                    .requestJWT(guid: guid, sharedKey: sharedKey)
                    .replaceError(with: JWTServiceError.failedToRetrieveJWTToken)
            }
            .eraseToAnyPublisher()
    }

    private let client: JWTClientAPI
    private let credentialsRepository: CredentialsRepositoryAPI

    init(
        client: JWTClientAPI = resolve(),
        credentialsRepository: CredentialsRepositoryAPI = resolve()
    ) {
        self.client = client
        self.credentialsRepository = credentialsRepository
    }
}
