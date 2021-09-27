// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol BitcoinCashHistoricalTransactionServiceAPI: AnyObject {
    func transactions(publicKeys: [XPub]) -> Single<[BitcoinCashHistoricalTransaction]>
    func transaction(publicKeys: [XPub], identifier: String) -> Single<BitcoinCashHistoricalTransaction>
}

final class BitcoinCashHistoricalTransactionService: BitcoinCashHistoricalTransactionServiceAPI {

    private enum ServiceError: Error {
        case errorFetchingDetails
    }

    private let client: APIClientAPI
    private let cache: Cache<[XPub], [BitcoinCashHistoricalTransaction]>

    init(with client: APIClientAPI = resolve()) {
        self.client = client
        cache = .init(entryLifetime: 60)
    }

    func transactions(publicKeys: [XPub]) -> Single<[BitcoinCashHistoricalTransaction]> {
        guard let response = cache.value(forKey: publicKeys) else {
            return client
                .multiAddress(for: publicKeys)
                .map(\.transactions)
                .do(onSuccess: { [cache] transactions in
                    cache.set(transactions, forKey: publicKeys)
                })
        }
        return .just(response)
    }

    // It is not possible to fetch a specific transaction detail from 'multiaddr' endpoints,
    //   so we fetch the first page and filter out the transaction from there.
    //   This may cause a edge case where a user opens the last transaction of the list, but
    //   in the mean time there was a new transaction added, making it 'drop' out of the first
    //   page. The fix for this is to have a properly paginated multiaddr/details endpoint.
    func transaction(publicKeys: [XPub], identifier: String) -> Single<BitcoinCashHistoricalTransaction> {
        transactions(publicKeys: publicKeys)
            .map { items -> BitcoinCashHistoricalTransaction? in
                items.first { $0.identifier == identifier }
            }
            .onNil(error: ServiceError.errorFetchingDetails)
    }
}
