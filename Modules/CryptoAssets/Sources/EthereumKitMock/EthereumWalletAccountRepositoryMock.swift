// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
@testable import EthereumKit
import Foundation
import PlatformKit
import RxSwift

class EthereumWalletAccountRepositoryMock: EthereumWalletAccountRepositoryAPI, KeyPairProviderAPI {

    var keyPairValue = Single.just(MockEthereumWalletTestData.keyPair)
    var keyPair: Single<EthereumKeyPair> {
        keyPairValue
    }

    func keyPair(with secondPassword: String?) -> Single<EthereumKeyPair> {
        keyPairValue
    }

    static let ethereumWalletAccount = EthereumWalletAccount(
        index: 0,
        publicKey: "",
        label: "",
        archived: false
    )

    var defaultAccountValue: EthereumWalletAccount = ethereumWalletAccount
    var defaultAccount: Single<EthereumWalletAccount> {
        .just(defaultAccountValue)
    }

    var accounts: Single<[EthereumWalletAccount]> {
        defaultAccount.map { [$0] }
    }

    var activeAccounts: Single<[EthereumWalletAccount]> {
        accounts
    }
}
