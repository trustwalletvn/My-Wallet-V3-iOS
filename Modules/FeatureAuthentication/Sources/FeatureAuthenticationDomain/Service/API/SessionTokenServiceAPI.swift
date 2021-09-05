// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public enum SessionTokenServiceError: Error {
    case networkError(NetworkError)
    case missingSessionToken
}

public protocol SessionTokenServiceAPI: AnyObject {
    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError>
}

public func sessionTokenServiceFactory(walletRepository: SessionTokenRepositoryAPI) -> SessionTokenServiceAPI {
    SessionTokenService(walletRepository: walletRepository)
}
