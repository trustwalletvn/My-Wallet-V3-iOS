// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol LanguageRepositoryCombineAPI: AnyObject {
    func setPublisher(language: String) -> AnyPublisher<Void, Never>
}

public protocol LanguageRepositoryAPI: LanguageRepositoryCombineAPI {
    func set(language: String) -> Completable
}
