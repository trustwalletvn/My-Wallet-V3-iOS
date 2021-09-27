// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import EthereumKit
import NetworkKit
import PlatformKit
import RxSwift
import ToolKit

protocol ERC20HistoricalTransactionServiceAPI: AnyObject {
    func transactions(erc20Asset: ERC20AssetModel, address: EthereumAddress) -> Single<[ERC20HistoricalTransaction]>
}

final class ERC20HistoricalTransactionService: ERC20HistoricalTransactionServiceAPI {

    private enum ServiceError: Error {
        case errorFetchingDetails
    }

    private struct Key: Hashable {
        let erc20Asset: ERC20AssetModel
        let address: EthereumAddress
    }

    private let accountClient: ERC20AccountAPIClientAPI
    private let cache: Cache<Key, [ERC20HistoricalTransaction]>

    init(accountClient: ERC20AccountAPIClientAPI = resolve()) {
        self.accountClient = accountClient
        cache = .init(entryLifetime: 60)
    }

    func transactions(erc20Asset: ERC20AssetModel, address: EthereumAddress) -> Single<[ERC20HistoricalTransaction]> {
        let key = Key(erc20Asset: erc20Asset, address: address)
        guard let response = cache.value(forKey: key) else {
            return accountClient
                .fetchTransactions(from: address.publicKey, page: nil, contractAddress: erc20Asset.contractAddress.publicKey)
                .map(\.transfers)
                .map { transfers in
                    transfers.map { item in
                        ERC20HistoricalTransaction(
                            response: item,
                            cryptoCurrency: .erc20(erc20Asset),
                            source: address
                        )
                    }
                }
                .do(onSuccess: { [cache] response in
                    cache.set(response, forKey: key)
                })
        }
        return .just(response)
    }
}
