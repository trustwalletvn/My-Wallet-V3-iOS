// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol SessionTokenRepositoryCombineAPI: AnyObject {

    /// Streams `Bool` indicating whether a session token is currently cached in the repo
    var hasSessionTokenPublisher: AnyPublisher<Bool, Never> { get }

    /// Streams the cached session token or `nil` if it is not cached
    var sessionTokenPublisher: AnyPublisher<String?, Never> { get }

    /// Sets the session token
    func setPublisher(sessionToken: String) -> AnyPublisher<Void, Never>

    /// Cleans the session token
    func cleanSessionTokenPublisher() -> AnyPublisher<Void, Never>
}

public protocol SessionTokenRepositoryAPI: SessionTokenRepositoryCombineAPI {

    /// Streams `Bool` indicating whether a session token is currently cached in the repo
    var hasSessionToken: Single<Bool> { get }

    /// Streams the cached session token or `nil` if it is not cached
    var sessionToken: Single<String?> { get }

    /// Sets the session token
    func set(sessionToken: String) -> Completable

    /// Cleans the session token
    func cleanSessionToken() -> Completable
}

extension SessionTokenRepositoryAPI {
    public var hasSessionToken: Single<Bool> {
        sessionToken
            .map { token in
                guard let token = token else { return false }
                return !token.isEmpty
            }
    }

    public var hasSessionTokenPublisher: AnyPublisher<Bool, Never> {
        sessionTokenPublisher
            .flatMap { token -> AnyPublisher<Bool, Never> in
                guard let token = token else { return .just(false) }
                return .just(!token.isEmpty)
            }
            .eraseToAnyPublisher()
    }
}
