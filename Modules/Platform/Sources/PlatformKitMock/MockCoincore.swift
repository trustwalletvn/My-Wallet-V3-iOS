// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

class MockCoincore: CoincoreAPI {

    var allAccounts: Single<AccountGroup> = Observable<AccountGroup>.empty().asSingle()
    var allAssets: [Asset] = []
    var fiatAsset: Asset = MockAsset()
    var cryptoAssets: [CryptoAsset] = []

    func initialize() -> Completable {
        .just(event: .completed)
    }

    var initializePublisherCalled = false

    func initializePublisher() -> AnyPublisher<Never, Never> {
        initializePublisherCalled = true
        return initialize().asPublisher().ignoreFailure()
    }

    func getTransactionTargets(sourceAccount: BlockchainAccount, action: AssetAction) -> Single<[SingleAccount]> {
        .just([])
    }

    var requestedCryptoAsset: CryptoAsset!

    subscript(cryptoCurrency: CryptoCurrency) -> CryptoAsset {
        requestedCryptoAsset
    }
}

class MockAsset: Asset {
    func initialize() -> Completable {
        .empty()
    }

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup> {
        .never()
    }

    func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]> {
        .never()
    }

    func parse(address: String) -> Single<ReceiveAddress?> {
        .never()
    }
}
