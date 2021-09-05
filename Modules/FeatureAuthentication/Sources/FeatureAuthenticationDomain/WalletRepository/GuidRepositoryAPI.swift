// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol GuidRepositoryCombineAPI: AnyObject {

    /// Streams `Bool` indicating whether the guid is currently cached in the repo
    var hasGuidPublisher: AnyPublisher<Bool, Never> { get }

    /// Streams the cached guid or `nil` if it is not cached
    var guidPublisher: AnyPublisher<String?, Never> { get }

    /// Sets the guid
    func setPublisher(guid: String) -> AnyPublisher<Void, Never>
}

public protocol GuidRepositoryAPI: GuidRepositoryCombineAPI {

    /// Streams `Bool` indicating whether the guid is currently cached in the repo
    var hasGuid: Single<Bool> { get }

    /// Streams the cached guid or `nil` if it is not cached
    var guid: Single<String?> { get }

    /// Sets the guid
    func set(guid: String) -> Completable
}

extension GuidRepositoryAPI {

    public var hasGuid: Single<Bool> {
        guid.map { $0?.isEmpty == false }
    }

    public var hasGuidPublisher: AnyPublisher<Bool, Never> {
        guidPublisher
            .flatMap { guid -> AnyPublisher<Bool, Never> in
                guard let guid = guid else { return .just(false) }
                return .just(!guid.isEmpty)
            }
            .eraseToAnyPublisher()
    }
}
