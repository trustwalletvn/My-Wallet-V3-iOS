// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

public final class WalletPayloadService: WalletPayloadServiceAPI {

    // MARK: - Types

    public typealias WalletRepositoryAPI = GuidRepositoryAPI &
        SessionTokenRepositoryAPI &
        SharedKeyRepositoryAPI &
        LanguageRepositoryAPI &
        SyncPubKeysRepositoryAPI &
        AuthenticatorRepositoryAPI &
        PayloadRepositoryAPI

    // MARK: - Properties

    private let client: WalletPayloadClientAPI
    private let repository: WalletRepositoryAPI

    // MARK: - Setup

    public init(client: WalletPayloadClientAPI = WalletPayloadClient(), repository: WalletRepositoryAPI) {
        self.client = client
        self.repository = repository
    }

    // MARK: - API

    public func requestUsingSessionToken() -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let request = request(guid:sessionToken:)
        return repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), WalletPayloadServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { credentials -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                request(credentials.guid, credentials.sessionToken)
            }
            .eraseToAnyPublisher()
    }

    public func requestUsingSharedKey() -> AnyPublisher<Void, WalletPayloadServiceError> {
        let request = request(guid:sharedKey:)
        return repository.guidPublisher
            .zip(repository.sharedKeyPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sharedKey: String), WalletPayloadServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sharedKey = credentials.1 else {
                    return .failure(.missingCredentials(.sharedKey))
                }
                return .just((guid, sharedKey))
            }
            .flatMap { credentials -> AnyPublisher<Void, WalletPayloadServiceError> in
                request(credentials.guid, credentials.sharedKey)
            }
            .eraseToAnyPublisher()
    }

    public func request(guid: String, sharedKey: String) -> AnyPublisher<Void, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return client
            .payload(guid: guid, identifier: .sharedKey(sharedKey))
            .mapError(WalletPayloadServiceError.init)
            .flatMap { response -> AnyPublisher<Void, WalletPayloadServiceError> in
                cacheWalletData(response)
                    .mapToVoid()
            }
            .eraseToAnyPublisher()
    }

    public func request(guid: String, sessionToken: String) -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> {
        let cacheWalletData = cacheWalletData(from:)
        return client
            .payload(guid: guid, identifier: .sessionToken(sessionToken))
            .mapError(WalletPayloadServiceError.init)
            .flatMap { response -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError> in
                cacheWalletData(response)
            }
            .flatMap { response -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: response.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return .just(type)
            }
            .catch { error -> AnyPublisher<WalletAuthenticatorType, WalletPayloadServiceError> in
                switch error {
                case .emailAuthorizationRequired:
                    return .just(.email)
                default:
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    public func cacheWalletData(
        from clientResponse: WalletPayloadClient.ClientResponse
    ) -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError> {
        repository.setPublisher(guid: clientResponse.guid)
            .zip(repository.setPublisher(language: clientResponse.language))
            .zip(repository.setPublisher(syncPubKeys: clientResponse.shouldSyncPubkeys))
            .flatMap { [repository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                guard let type = WalletAuthenticatorType(rawValue: clientResponse.authType) else {
                    return .failure(.unsupported2FAType)
                }
                return repository.setPublisher(authenticatorType: type)
                    .mapError()
            }
            .flatMap { [repository] _ -> AnyPublisher<Void, WalletPayloadServiceError> in
                if let rawPayload = clientResponse.payload?.stringRepresentation, !rawPayload.isEmpty {
                    return repository.setPublisher(payload: rawPayload)
                        .mapError()
                }
                return .just(())
            }
            .flatMap { _ -> AnyPublisher<WalletPayloadClient.ClientResponse, WalletPayloadServiceError> in
                .just(clientResponse)
            }
            .eraseToAnyPublisher()
    }
}

// MARK: - WalletPayloadServiceError

extension WalletPayloadServiceError {
    init(clientError: WalletPayloadClient.ClientError) {
        switch clientError {
        case .missingPayload:
            self = .missingPayload
        case .missingGuid:
            self = .missingCredentials(.guid)
        case .emailAuthorizationRequired:
            self = .emailAuthorizationRequired
        case .accountLocked:
            self = .accountLocked
        case .message(let message):
            self = .message(message)
        case .unknown:
            self = .unknown
        }
    }
}
