//
//  NabuAuthenticationExecutor.swift
//  PlatformKit
//
//  Created by Jack Pooley on 29/03/2021.
//  Copyright © 2021 Blockchain Luxembourg S.A. All rights reserved.
//

import Combine
import DIKit
import NetworkKit
import ToolKit

public protocol NabuAuthenticationExecutorAPI {
    
    /// Runs authentication flow if needed and passes it to the `networkResponsePublisher`
    /// - Parameter networkResponsePublisher: the closure taking a token and returning a publisher for a request
    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError>
}

public typealias NabuAuthenticationExecutorProvider = () -> NabuAuthenticationExecutorAPI

public enum NabuAuthenticationExecutorError: Error {
    case failedToCreateUser(NetworkCommunicatorError)
    case failedToRetrieveJWTToken(JWTServiceError)
    case failedToRecoverUser(NetworkCommunicatorError)
    case failedToFetchSettings(SettingsServiceError)
    case failedToGetSessionToken(NetworkCommunicatorError)
    case sessionTokenFetchTimedOut
    case missingCredentials(MissingCredentialsError)
    case failedToSaveOfflineToken(CredentialWritingError)
    case communicatorError(NetworkCommunicatorError)
}

struct NabuAuthenticationExecutor: NabuAuthenticationExecutorAPI {
    
    typealias CredentialsRepository = CredentialsRepositoryAPI & NabuOfflineTokenRepositoryCombineAPI
    
    private struct Token {
        let sessionToken: NabuSessionTokenResponse
        let offlineToken: NabuOfflineTokenResponse
    }
    
    private let store: NabuTokenStore
    private let userCreationClient: UserCreationClientAPI
    private let credentialsRepository: CredentialsRepository
    private let deviceInfo: DeviceInfo
    private let jwtService: JWTServiceAPI
    private let authenticationClient: NabuAuthenticationClientAPI
    private let settingsService: SettingsServiceAPI
    private let siftService: SiftServiceAPI
    private let queue: DispatchQueue
    
    private let fetchTokensPublisher: Atomic<AnyPublisher<Token, NabuAuthenticationExecutorError>?> = Atomic(nil)
    
    init(userCreationClient: UserCreationClientAPI = resolve(),
         store: NabuTokenStore = resolve(),
         settingsService: SettingsServiceAPI = resolve(),
         siftService: SiftServiceAPI = resolve(),
         jwtService: JWTServiceAPI = resolve(),
         authenticationClient: NabuAuthenticationClientAPI = resolve(),
         credentialsRepository: NabuAuthenticationExecutor.CredentialsRepository = resolve(),
         deviceInfo: DeviceInfo = resolve(),
         queue: DispatchQueue =
            DispatchQueue(
                label: "com.blockchain.NabuAuthenticationExecutorNew",
                qos: .background
            )
    ) {
        self.userCreationClient = userCreationClient
        self.store = store
        self.settingsService = settingsService
        self.siftService = siftService
        self.credentialsRepository = credentialsRepository
        self.jwtService = jwtService
        self.authenticationClient = authenticationClient
        self.deviceInfo = deviceInfo
        self.queue = queue
    }
    
    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> {
        getToken()
            .mapError(NetworkCommunicatorError.authentication)
            .flatMap { payload -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> in
                networkResponsePublisher(payload.sessionToken.token)
                    .catch { communicatorError -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> in
                        refreshOrReturnError(
                            communicatorError: communicatorError,
                            offlineToken: payload.offlineToken,
                            publisherProvider: networkResponsePublisher
                        )
                        .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Private methods
    
    private func getToken() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        Publishers.Zip(store.sessionTokenDataPublisher.mapError(), retrieveOfflineTokenResponse())
            .map { sessionToken, offlineToken -> (sessionToken: NabuSessionTokenResponse?, offlineToken: NabuOfflineTokenResponse) in
                (sessionToken: sessionToken, offlineToken: offlineToken)
            }
            // swiftlint:disable:next line_length
            .catch { _ -> AnyPublisher<(sessionToken: NabuSessionTokenResponse?, offlineToken: NabuOfflineTokenResponse), NabuAuthenticationExecutorError> in
                fetchTokens()
                    .map { token -> (sessionToken: NabuSessionTokenResponse?, offlineToken: NabuOfflineTokenResponse) in
                        (token.sessionToken, token.offlineToken)
                    }
                    .eraseToAnyPublisher()
            }
            .flatMap { payload -> AnyPublisher<Token, NabuAuthenticationExecutorError> in
                guard let token = payload.sessionToken else {
                    return fetchTokens()
                }
                return .just(Token(sessionToken: token, offlineToken: payload.offlineToken))
            }
            .eraseToAnyPublisher()
    }
    
    private func fetchTokens() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        // Case A: We are already performing a token fetch, return current fetch publisher
        if let publisher = fetchTokensPublisher.value {
            return publisher
        }
        
        // Case B: We are not currently performing a token fetch, create a new fetch publisher
        let publisher = createFetchTokensPublisher()
            .handleEvents(receiveCompletion: { _ in
                
                // We are done fetching the token, reset state
                self.fetchTokensPublisher.mutate { $0 = nil }
            })
            .eraseToAnyPublisher()
        
        fetchTokensPublisher.mutate { $0 = publisher }
        
        return publisher
    }
    
    private func createFetchTokensPublisher() -> AnyPublisher<Token, NabuAuthenticationExecutorError> {
        createUserIfNeeded()
            .flatMap { offlineToken -> AnyPublisher<Token, NabuAuthenticationExecutorError> in
                currentToken(offlineToken: offlineToken)
                    .map { Token(sessionToken: $0, offlineToken: offlineToken) }
                    .eraseToAnyPublisher()
            }
            .share()
            .eraseToAnyPublisher()
    }
    
    private func currentToken(
        offlineToken: NabuOfflineTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> {
        store.requiresRefresh
            .mapError()
            .flatMap { requiresRefresh -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                guard !requiresRefresh else {
                    return refreshToken(offlineToken: offlineToken)
                }
                return store.sessionTokenDataPublisher
                    .mapError()
                    .flatMap { sessionToken -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                        guard let sessionToken = sessionToken else {
                            return .failure(.missingCredentials(MissingCredentialsError.sessionToken))
                        }
                        return .just(sessionToken)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    private func refreshOrReturnError(
        communicatorError: NetworkCommunicatorError,
        offlineToken: NabuOfflineTokenResponse,
        publisherProvider: @escaping (String) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError>
    ) -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> {
        unauthenticated(communicatorError: communicatorError)
            .mapError()
            .flatMap { unauthenticated -> AnyPublisher<Void, NetworkCommunicatorError> in
                guard unauthenticated else {
                    return .failure(communicatorError)
                }
                return clearAccessToken()
                    .mapError()
                    .eraseToAnyPublisher()
            }
            .flatMap { _ -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> in
                refreshToken(offlineToken: offlineToken)
                    .mapError(NetworkCommunicatorError.authentication)
                    .flatMap { sessionToken -> AnyPublisher<ServerResponseNew, NetworkCommunicatorError> in
                        publisherProvider(sessionToken.token)
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func refreshToken(
        offlineToken: NabuOfflineTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> {
        getSessionToken(offlineTokenResponse: offlineToken)
            .flatMap { sessionTokenResponse -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                store.store(sessionTokenResponse)
                    .mapError()
            }
            .catch { error -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                recoverOrReturnError(error: error, offlineToken: offlineToken)
            }
            .eraseToAnyPublisher()
    }
    
    private func unauthenticated(
        communicatorError: NetworkCommunicatorError
    ) -> AnyPublisher<Bool, Never> {
        guard let authenticationError = NabuAuthenticationError(communicatorError: communicatorError) else {
            return AnyPublisher<Bool, Never>.just(false)
                .eraseToAnyPublisher()
        }
        return AnyPublisher<Bool, Never>.just(authenticationError == .tokenExpired)
            .eraseToAnyPublisher()
    }
    
    private func clearAccessToken() -> AnyPublisher<Void, Never> {
        store.invalidate().mapError()
            .eraseToAnyPublisher()
    }
    
    private func getSessionToken(
        offlineTokenResponse: NabuOfflineTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> {
        
        let email = settingsService.singleValuePublisher
            .map(\.email)
            .mapError(NabuAuthenticationExecutorError.failedToFetchSettings)
            .eraseToAnyPublisher()
        
        let guid = credentialsRepository.guidPublisher
            .mapError()
            .flatMap { guid -> AnyPublisher<String, NabuAuthenticationExecutorError> in
                guard let guid = guid else {
                    return .failure(.missingCredentials(MissingCredentialsError.guid))
                }
                return .just(guid)
            }
            .eraseToAnyPublisher()
        
        return Publishers.Zip(email, guid)
            .flatMap { email, guid -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                authenticationClient
                    .sessionTokenPublisher(
                        for: guid,
                        userToken: offlineTokenResponse.token,
                        userIdentifier: offlineTokenResponse.userId,
                        deviceId: deviceInfo.uuidString,
                        email: email
                    )
                    .mapError(NabuAuthenticationExecutorError.failedToGetSessionToken)
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { nabuSessionTokenResponse in
                siftService.set(
                    userId: nabuSessionTokenResponse.userId
                )
            })
            .eraseToAnyPublisher()
    }
    
    private func recoverOrReturnError(
        error: NabuAuthenticationExecutorError,
        offlineToken: NabuOfflineTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> {
        guard case .communicatorError(let communicatorError) = error else {
            return AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError>.failure(error)
                .eraseToAnyPublisher()
        }
        return userRestored(communicatorError: communicatorError)
            .mapError()
            .flatMap { userRestored -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                guard userRestored else {
                    return .failure(error)
                }
                return recoverUserAndContinue(offlineToken: offlineToken)
            }
            .eraseToAnyPublisher()
    }
    
    private func userRestored(
        communicatorError: NetworkCommunicatorError
    ) -> AnyPublisher<Bool, Never> {
        guard let authenticationError = NabuAuthenticationError(communicatorError: communicatorError) else {
            return AnyPublisher<Bool, Never>.just(false)
                .eraseToAnyPublisher()
        }
        return AnyPublisher<Bool, Never>.just(authenticationError == .alreadyRegistered)
            .eraseToAnyPublisher()
    }
    
    private func recoverUserAndContinue(
        offlineToken: NabuOfflineTokenResponse
    ) -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> {
        jwtToken()
            .flatMap { jwtToken -> AnyPublisher<Void, NabuAuthenticationExecutorError> in
                authenticationClient.recoverUserPublisher(offlineToken: offlineToken, jwt: jwtToken)
                    .mapError(NabuAuthenticationExecutorError.failedToRecoverUser)
                    .eraseToAnyPublisher()
            }
            .flatMap { _ -> AnyPublisher<NabuSessionTokenResponse, NabuAuthenticationExecutorError> in
                refreshToken(offlineToken: offlineToken)
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - User Creation
    
    private func createUserIfNeeded() -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> {
        credentialsRepository.offlineTokenResponsePublisher
            .catch { _ -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> in
                createUser()
            }
            .eraseToAnyPublisher()
    }

    private func createUser() -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> {
        jwtToken()
            .flatMap { jwtToken -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> in
                userCreationClient.createUser(for: jwtToken)
                    .mapError(NabuAuthenticationExecutorError.failedToCreateUser)
                    .eraseToAnyPublisher()
            }
            .flatMap { offlineTokenResponse -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> in
                credentialsRepository
                    .setPublisher(offlineTokenResponse: offlineTokenResponse)
                    .replaceOutput(with: offlineTokenResponse)
                    .mapError(NabuAuthenticationExecutorError.failedToSaveOfflineToken)
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Conveniences
    
    private func jwtToken() -> AnyPublisher<String, NabuAuthenticationExecutorError> {
        jwtService.token
            .mapError(NabuAuthenticationExecutorError.failedToRetrieveJWTToken)
            .eraseToAnyPublisher()
    }
    
    private func retrieveOfflineTokenResponse() -> AnyPublisher<NabuOfflineTokenResponse, NabuAuthenticationExecutorError> {
        credentialsRepository.offlineTokenResponsePublisher
            .mapError(NabuAuthenticationExecutorError.missingCredentials)
            .eraseToAnyPublisher()
    }
}
