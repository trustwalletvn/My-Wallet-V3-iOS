// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import PlatformKit
import RxSwift

class TransactionClientAPIMock: TransactionClientAPI {
    var latestBlockValue: Single<LatestBlockResponse> = Single.error(EthereumAPIClientMockError.mockError)
    var latestBlock: Single<LatestBlockResponse> {
        latestBlockValue
    }

    var transactionValue: Single<EthereumHistoricalTransactionResponse> = .error(EthereumAPIClientMockError.mockError)

    func transaction(with hash: String) -> Single<EthereumHistoricalTransactionResponse> {
        transactionValue
    }

    var lastTransactionsForAccount: String?
    var transactionsForAccountValue: Single<[EthereumHistoricalTransactionResponse]> = .just([])

    func transactions(for account: String) -> Single<[EthereumHistoricalTransactionResponse]> {
        lastTransactionsForAccount = account
        return transactionsForAccountValue
    }
}
