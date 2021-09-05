// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public enum PasswordRepositoryError: Error {
    case unavailable
    case syncFailed
}

public protocol PasswordRepositoryCombineAPI: AnyObject {

    /// Streams `Bool` indicating whether a password is currently cached in the repo
    var hasPasswordPublisher: AnyPublisher<Bool, Never> { get }

    /// Streams the cached password or `nil` if it is not cached
    var passwordPublisher: AnyPublisher<String?, Never> { get }

    /// Sets the password
    func setPublisher(password: String) -> AnyPublisher<Void, Never>

    /// Syncs the current `password` with the users wallet.
    /// This changes the users password.
    func syncPublisher() -> AnyPublisher<Void, PasswordRepositoryError>
}

public protocol PasswordRepositoryAPI: PasswordRepositoryCombineAPI {

    /// Streams `Bool` indicating whether a password is currently cached in the repo
    var hasPassword: Single<Bool> { get }

    /// Streams the cached password or `nil` if it is not cached
    var password: Single<String?> { get }

    /// Sets the password
    func set(password: String) -> Completable

    /// Syncs the current `password` with the users wallet.
    /// This changes the users password.
    func sync() -> Completable
}

extension PasswordRepositoryAPI {
    public var hasPassword: Single<Bool> {
        password
            .map { password in
                guard let password = password else { return false }
                return !password.isEmpty
            }
    }
}
