// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit

final class SessionTokenService: SessionTokenServiceAPI {

    // MARK: - Injected

    private let repository: RemoteSessionTokenRepositoryAPI
    private let walletRepository: SessionTokenRepositoryAPI

    // MARK: - Setup

    init(
        repository: RemoteSessionTokenRepositoryAPI = resolve(),
        walletRepository: SessionTokenRepositoryAPI
    ) {
        self.repository = repository
        self.walletRepository = walletRepository
    }

    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        walletRepository
            .hasSessionTokenPublisher
            .flatMap { [repository, walletRepository] hasSessionToken
                -> AnyPublisher<String?, SessionTokenServiceError> in
                guard !hasSessionToken else {
                    return walletRepository
                        .sessionToken
                        .asPublisher()
                        .ignoreFailure(setFailureType: SessionTokenServiceError.self)
                }
                return repository
                    .token
                    .eraseToAnyPublisher()
            }
            .flatMap { sessionTokenOrNil
                -> AnyPublisher<String, SessionTokenServiceError> in
                guard let sessionToken = sessionTokenOrNil else {
                    return .failure(.missingSessionToken)
                }
                return .just(sessionToken)
            }
            .flatMap { [walletRepository] sessionToken
                -> AnyPublisher<Void, SessionTokenServiceError> in
                walletRepository.setPublisher(sessionToken: sessionToken)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}
