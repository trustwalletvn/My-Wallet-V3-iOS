// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol PayloadRepositoryCombineAPI: AnyObject {
    func setPublisher(payload: String) -> AnyPublisher<Void, Never>
}

public protocol PayloadRepositoryAPI: PayloadRepositoryCombineAPI {
    func set(payload: String) -> Completable
}
