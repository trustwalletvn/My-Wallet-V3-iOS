// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import WalletPayloadKit

public final class TwoFAWalletService: TwoFAWalletServiceAPI {

    // MARK: - Type

    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI & PayloadRepositoryAPI

    // MARK: - Properties

    private let client: TwoFAWalletClientAPI
    private let repository: WalletRepositoryAPI

    // MARK: - Setup

    public init(client: TwoFAWalletClientAPI, repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    // MARK: - API

    public func send(code: String) -> AnyPublisher<Void, TwoFAWalletServiceError> {
        // Trim whitespaces before verifying and sending
        let code = code.trimmingWhitespaces

        // Verify the code is not empty to save network call
        guard !code.isEmpty else {
            return .failure(.missingCode)
        }

        return repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), TwoFAWalletServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [client] credentails -> AnyPublisher<WalletPayloadWrapper, TwoFAWalletServiceError> in
                client.payload(
                    guid: credentails.guid,
                    sessionToken: credentails.sessionToken,
                    code: code
                )
                .mapError { error in
                    switch error {
                    case .wrongCode(attemptsLeft: let attemptsLeft):
                        return .wrongCode(attemptsLeft: attemptsLeft)
                    case .accountLocked:
                        return .accountLocked
                    case .networkError(let error):
                        return .networkError(error)
                    }
                }
                .eraseToAnyPublisher()
            }
            .flatMap { response -> AnyPublisher<String, TwoFAWalletServiceError> in
                guard let rawPayload = response.stringRepresentation, !rawPayload.isEmpty else {
                    return .failure(.missingPayload)
                }
                return .just(rawPayload)
            }
            .flatMap { [repository] rawPayload -> AnyPublisher<Void, TwoFAWalletServiceError> in
                repository.setPublisher(payload: rawPayload)
                    .mapError()
            }
            .eraseToAnyPublisher()
    }
}
