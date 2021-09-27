// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift

final class BitcoinCashActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = BitcoinCashActivityItemEventDetails

    private let bridge: BitcoinCashWalletBridgeAPI
    private let transactionsService: BitcoinCashHistoricalTransactionServiceAPI

    init(
        transactionsService: BitcoinCashHistoricalTransactionServiceAPI = resolve(),
        bridge: BitcoinCashWalletBridgeAPI = resolve()
    ) {
        self.transactionsService = transactionsService
        self.bridge = bridge
    }

    func details(for identifier: String) -> Observable<BitcoinCashActivityItemEventDetails> {
        bridge.wallets
            .map { wallet -> [XPub] in
                wallet.map(\.publicKey)
            }
            .flatMap { [transactionsService] publicKeys -> Single<BitcoinCashActivityItemEventDetails> in
                transactionsService
                    .transaction(publicKeys: publicKeys, identifier: identifier)
                    .map(BitcoinCashActivityItemEventDetails.init(transaction:))
            }
            .asObservable()
    }
}
