// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxSwift

public protocol EthereumTransactionDispatcherAPI {
    func send(transaction: EthereumTransactionCandidate, secondPassword: String) -> Single<EthereumTransactionPublished>
}

final class EthereumTransactionDispatcher: EthereumTransactionDispatcherAPI {

    private let bridge: EthereumWalletBridgeAPI
    private let keyPairProvider: AnyKeyPairProvider<EthereumKeyPair>
    private let transactionSendingService: EthereumTransactionSendingServiceAPI

    init(
        with bridge: EthereumWalletBridgeAPI = resolve(),
        keyPairProvider: AnyKeyPairProvider<EthereumKeyPair> = resolve(),
        transactionSendingService: EthereumTransactionSendingServiceAPI = resolve()
    ) {
        self.bridge = bridge
        self.keyPairProvider = keyPairProvider
        self.transactionSendingService = transactionSendingService
    }

    func send(transaction: EthereumTransactionCandidate, secondPassword: String) -> Single<EthereumTransactionPublished> {
        keyPairProvider.keyPair(with: secondPassword)
            .flatMap(weak: self) { (self, keyPair) -> Single<EthereumTransactionPublished> in
                self.transactionSendingService.send(
                    transaction: transaction,
                    keyPair: keyPair
                )
            }
            .flatMap(weak: self) { (self, transaction) -> Single<EthereumTransactionPublished> in
                self.updateAfterSending(transaction: transaction)
            }
    }

    private func updateAfterSending(transaction: EthereumTransactionPublished) -> Single<EthereumTransactionPublished> {
        bridge.recordLast(transaction: transaction)
    }
}
