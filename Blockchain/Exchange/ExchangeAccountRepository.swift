// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import BitcoinKit
import Combine
import DIKit
import FeatureSettingsDomain
import NetworkKit
import PlatformKit
import RxSwift

protocol ExchangeAccountRepositoryAPI {
    var hasLinkedExchangeAccount: Single<Bool> { get }

    func syncDepositAddresses() -> Completable
    func syncDepositAddressesIfLinked() -> Completable
    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error>
}

enum ExchangeLinkingAPIError: Error {
    case noLinkID
    case unknown
}

final class ExchangeAccountRepository: ExchangeAccountRepositoryAPI {

    private let blockchainRepository: BlockchainDataRepository
    private let clientAPI: ExchangeClientAPI
    private let coincore: CoincoreAPI

    init(
        blockchainRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
        client: ExchangeClientAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.blockchainRepository = blockchainRepository
        clientAPI = client
        self.coincore = coincore
    }

    var hasLinkedExchangeAccount: Single<Bool> {
        blockchainRepository
            .nabuUserSingle
            .map(\.hasLinkedExchangeAccount)
    }

    func syncDepositAddressesIfLinked() -> Completable {
        hasLinkedExchangeAccount
            .flatMapCompletable(weak: self) { (self, linked) -> Completable in
                if linked {
                    return self.syncDepositAddresses()
                } else {
                    return Completable.empty()
                }
            }
    }

    func syncDepositAddressesIfLinkedPublisher() -> AnyPublisher<Void, Error> {
        syncDepositAddressesIfLinked()
            .asPublisher()
            .mapToVoid()
    }

    func syncDepositAddresses() -> Completable {
        Single
            .just(coincore.cryptoAssets)
            .flatMap { cryptoAssets -> Single<[SingleAccount?]> in
                Single.zip(
                    cryptoAssets
                        .map { asset -> Single<SingleAccount?> in
                            asset.defaultAccount
                                .optional()
                                .replaceError(with: nil)
                                .eraseToAnyPublisher()
                                .asObservable()
                                .asSingle()
                        }
                )
            }
            .map { accounts -> [SingleAccount] in
                accounts.compactMap { $0 }
            }
            .flatMap { accounts -> Single<[ReceiveAddress]> in
                Single.zip(accounts.map(\.receiveAddress))
            }
            .map { receiveAddresses -> [CryptoReceiveAddress] in
                receiveAddresses as? [CryptoReceiveAddress] ?? []
            }
            .flatMapCompletable(weak: self) { (self, receiveAddresses) in
                self.clientAPI.syncDepositAddress(accounts: receiveAddresses)
            }
    }
}
