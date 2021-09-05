// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol SyncPubKeysRepositoryCombineAPI: AnyObject {
    func setPublisher(syncPubKeys: Bool) -> AnyPublisher<Void, Never>
}

public protocol SyncPubKeysRepositoryAPI: SyncPubKeysRepositoryCombineAPI {
    func set(syncPubKeys: Bool) -> Completable
}
