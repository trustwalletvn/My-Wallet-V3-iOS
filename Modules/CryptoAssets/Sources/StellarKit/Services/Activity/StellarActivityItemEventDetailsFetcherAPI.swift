// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

final class StellarActivityItemEventDetailsFetcher: ActivityItemEventDetailsFetcherAPI {
    typealias Model = StellarActivityItemEventDetails

    private let repository: StellarWalletAccountRepositoryAPI
    private let operationsService: StellarHistoricalTransactionServiceAPI

    init(
        repository: StellarWalletAccountRepositoryAPI = resolve(),
        operationsService: StellarHistoricalTransactionServiceAPI = resolve()
    ) {
        self.repository = repository
        self.operationsService = operationsService
    }

    func details(for identifier: String) -> Observable<StellarActivityItemEventDetails> {
        guard let accountID = repository.defaultAccount?.publicKey else {
            return .error(StellarAccountError.noDefaultAccount)
        }
        return details(operationID: identifier, accountID: accountID)
    }

    private func details(operationID: String, accountID: String) -> Observable<StellarActivityItemEventDetails> {
        operationsService
            .transaction(accountID: accountID, operationID: operationID)
            .map(StellarActivityItemEventDetails.init)
            .asObservable()
    }
}
