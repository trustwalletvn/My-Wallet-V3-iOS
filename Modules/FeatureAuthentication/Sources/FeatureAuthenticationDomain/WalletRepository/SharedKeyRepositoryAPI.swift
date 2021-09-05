// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol SharedKeyRepositoryCombineAPI: AnyObject {
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKeyPublisher: AnyPublisher<Bool, Never> { get }

    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKeyPublisher: AnyPublisher<String?, Never> { get }

    /// Sets the shared key
    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never>
}

public protocol SharedKeyRepositoryAPI: SharedKeyRepositoryCombineAPI {
    /// Streams `Bool` indicating whether the shared key is currently cached in the repo
    var hasSharedKey: Single<Bool> { get }

    /// Streams the cached shared key or `nil` if it is not cached
    var sharedKey: Single<String?> { get }

    /// Sets the shared key
    func set(sharedKey: String) -> Completable
}

extension SharedKeyRepositoryAPI {
    public var hasSharedKey: Single<Bool> {
        sharedKey
            .map { sharedKey in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
    }

    public var hasSharedKeyPublisher: AnyPublisher<Bool, Never> {
        sharedKeyPublisher
            .map { sharedKey -> Bool in
                guard let sharedKey = sharedKey else { return false }
                return !sharedKey.isEmpty
            }
            .eraseToAnyPublisher()
    }
}

public protocol CredentialsRepositoryAPI: SharedKeyRepositoryAPI, GuidRepositoryAPI {
    var credentials: Single<(guid: String, sharedKey: String)> { get }

    var credentialsPublisher: AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> { get }
}

extension CredentialsRepositoryAPI {

    public var credentials: Single<(guid: String, sharedKey: String)> {
        Single
            .zip(guid, sharedKey)
            .map { guid, sharedKey -> (guid: String, sharedKey: String) in
                guard let guid = guid else {
                    throw MissingCredentialsError.guid
                }
                guard let sharedKey = sharedKey else {
                    throw MissingCredentialsError.sharedKey
                }
                return (guid, sharedKey)
            }
    }

    public var credentialsPublisher: AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> {
        guidPublisher
            .zip(sharedKeyPublisher)
            .flatMap { credentials -> AnyPublisher<(guid: String, sharedKey: String), MissingCredentialsError> in
                guard let guid = credentials.0 else {
                    return .failure(.guid)
                }
                guard let sharedKey = credentials.1 else {
                    return .failure(.sharedKey)
                }
                return .just((guid, sharedKey))
            }
            .eraseToAnyPublisher()
    }
}
