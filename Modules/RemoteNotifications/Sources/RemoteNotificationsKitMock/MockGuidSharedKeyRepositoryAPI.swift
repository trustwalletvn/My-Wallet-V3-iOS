// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import RxSwift

class MockGuidSharedKeyRepositoryAPI: GuidRepositoryAPI, SharedKeyRepositoryAPI {

    var hasGuidPublisher: AnyPublisher<Bool, Never> {
        guidPublisher.map { $0 != nil }.eraseToAnyPublisher()
    }

    var guidPublisher: AnyPublisher<String?, Never> {
        .just(expectedGuid)
    }

    func setPublisher(guid: String) -> AnyPublisher<Void, Never> {
        expectedGuid = guid
        return .just(())
    }

    var expectedGuid: String? = "123-abc-456-def-789-ghi"
    var expectedSharedKey: String? = "0123456789"

    var guid: Single<String?> {
        .just(expectedGuid)
    }

    func set(guid: String) -> Completable {
        expectedGuid = guid
        return .empty()
    }

    var sharedKey: Single<String?> {
        .just(expectedSharedKey)
    }

    var sharedKeyPublisher: AnyPublisher<String?, Never> {
        .just(expectedSharedKey)
    }

    func set(sharedKey: String) -> Completable {
        expectedSharedKey = sharedKey
        return .empty()
    }

    func setPublisher(sharedKey: String) -> AnyPublisher<Void, Never> {
        expectedSharedKey = sharedKey
        return .just(())
    }
}
