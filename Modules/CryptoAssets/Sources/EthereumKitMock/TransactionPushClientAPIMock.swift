// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import PlatformKit
import RxSwift

class TransactionPushClientAPIMock: TransactionPushClientAPI {
    var lastPushedTransaction: EthereumTransactionFinalised?
    var pushTransactionValue: Single<EthereumPushTxResponse> = .just(EthereumPushTxResponse(txHash: "txHash"))

    func push(transaction: EthereumTransactionFinalised) -> Single<EthereumPushTxResponse> {
        lastPushedTransaction = transaction
        return pushTransactionValue
    }
}
