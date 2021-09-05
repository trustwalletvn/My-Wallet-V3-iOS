// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import ToolKit

public final class SMSService: SMSServiceAPI {

    public typealias WalletRepositoryAPI = GuidRepositoryAPI & SessionTokenRepositoryAPI

    // MARK: - Properties

    private let client: SMSClientAPI
    private let repository: WalletRepositoryAPI

    public init(client: SMSClientAPI, repository: WalletRepositoryAPI) {
        self.repository = repository
        self.client = client
    }

    // MARK: - API

    public func request() -> AnyPublisher<Void, SMSServiceError> {
        repository.guidPublisher
            .zip(repository.sessionTokenPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sessionToken: String), SMSServiceError> in
                guard let guid = credentials.0 else {
                    return .failure(.missingCredentials(.guid))
                }
                guard let sessionToken = credentials.1 else {
                    return .failure(.missingCredentials(.sessionToken))
                }
                return .just((guid, sessionToken))
            }
            .flatMap { [client] credentials -> AnyPublisher<Void, SMSServiceError> in
                client.requestOTP(
                    sessionToken: credentials.sessionToken,
                    guid: credentials.guid
                )
                .mapError(SMSServiceError.networkError)
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}
