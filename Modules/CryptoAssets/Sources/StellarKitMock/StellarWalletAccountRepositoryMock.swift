// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformKit
import RxSwift
import StellarKit

class StellarWalletAccountRepositoryMock: StellarWalletAccountRepositoryAPI {

    var defaultAccount: StellarWalletAccount?

    func initializeMetadataMaybe() -> Maybe<StellarWalletAccount> {
        Maybe.empty()
    }

    func loadKeyPair() -> Maybe<StellarKeyPair> {
        Maybe.empty()
    }

    func loadKeyPair(with secondPassword: String?) -> Single<StellarKeyPair> {
        .never()
    }
}
