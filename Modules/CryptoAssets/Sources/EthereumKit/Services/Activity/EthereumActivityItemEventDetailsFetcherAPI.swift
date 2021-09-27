// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class EthereumActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = EthereumActivityItemEventDetails

    private let transactionService: EthereumHistoricalTransactionServiceAPI

    init(transactionService: EthereumHistoricalTransactionServiceAPI = resolve()) {
        self.transactionService = transactionService
    }

    func details(for identifier: String) -> Observable<EthereumActivityItemEventDetails> {
        transactionService
            .transaction(identifier: identifier)
            .map { EthereumActivityItemEventDetails(transaction: $0) }
            .asObservable()
    }
}
