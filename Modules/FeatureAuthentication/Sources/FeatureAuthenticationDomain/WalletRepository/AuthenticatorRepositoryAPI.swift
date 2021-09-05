// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import RxSwift

public protocol AuthenticatorRepositoryCombineAPI: AnyObject {

    /// Streams the authenticator type
    var authenticatorTypePublisher: AnyPublisher<WalletAuthenticatorType, Never> { get }

    /// Sets the authenticator type
    func setPublisher(authenticatorType: WalletAuthenticatorType) -> AnyPublisher<Void, Never>
}

public protocol AuthenticatorRepositoryAPI: AuthenticatorRepositoryCombineAPI {

    /// Streams the authenticator type
    var authenticatorType: Single<WalletAuthenticatorType> { get }

    /// Sets the authenticator type
    func set(authenticatorType: WalletAuthenticatorType) -> Completable
}
