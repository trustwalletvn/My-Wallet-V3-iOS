// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift

final class BitcoinActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = BitcoinActivityItemEventDetails

    private let bridge: BitcoinWalletBridgeAPI
    private let transactionsService: BitcoinHistoricalTransactionServiceAPI

    init(
        transactionsService: BitcoinHistoricalTransactionServiceAPI = resolve(),
        bridge: BitcoinWalletBridgeAPI = resolve()
    ) {
        self.transactionsService = transactionsService
        self.bridge = bridge
    }

    func details(for identifier: String) -> Observable<BitcoinActivityItemEventDetails> {
        bridge.wallets
            .map { wallet -> [XPub] in
                wallet.map(\.publicKeys).flatMap(\.xpubs)
            }
            .flatMap { [transactionsService] publicKeys -> Single<BitcoinActivityItemEventDetails> in
                transactionsService
                    .transaction(publicKeys: publicKeys, identifier: identifier)
                    .map(BitcoinActivityItemEventDetails.init(transaction:))
            }
            .asObservable()
    }
}
