// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public protocol EthereumHistoricalTransactionServiceAPI: AnyObject {
    var isWaitingOnTransaction: Single<Bool> { get }
    var transactions: Single<[EthereumHistoricalTransaction]> { get }

    func transaction(identifier: String) -> Single<EthereumHistoricalTransaction>
}

final class EthereumHistoricalTransactionService: EthereumHistoricalTransactionServiceAPI {

    // MARK: - Properties

    var transactions: Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.valueSingle
    }

    var isWaitingOnTransaction: Single<Bool> {
        fetchTransactions()
            .map { $0.contains(where: { $0.state == .pending }) }
            .catchErrorJustReturn(true)
    }

    // MARK: - Private properties

    private var latestBlock: Single<Int> {
        cachedLatestBlock.valueSingle
    }

    private var account: Single<EthereumAssetAccount> {
        cachedAccount.valueSingle
    }

    private let cachedAccount: CachedValue<EthereumAssetAccount>
    private let cachedTransactions: CachedValue<[EthereumHistoricalTransaction]>
    private let cachedLatestBlock: CachedValue<Int>
    private let bridge: EthereumWalletBridgeAPI
    private let client: TransactionClientAPI

    // MARK: - Init

    init(with bridge: EthereumWalletBridgeAPI = resolve(), client: TransactionClientAPI = resolve()) {
        self.bridge = bridge
        self.client = client
        cachedAccount = CachedValue<EthereumAssetAccount>(configuration: .onSubscription())
        cachedTransactions = CachedValue<[EthereumHistoricalTransaction]>(configuration: .periodic(60))
        cachedLatestBlock = CachedValue<Int>(configuration: .periodic(5))

        cachedAccount.setFetch { [weak self] () -> Single<EthereumAssetAccount> in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.bridge.account
        }

        cachedTransactions.setFetch { [weak self] () -> Single<[EthereumHistoricalTransaction]> in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetch()
        }

        cachedLatestBlock.setFetch { [weak self] () -> Single<Int> in
            guard let self = self else {
                return .error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchLatestBlock()
        }
    }

    /// Triggers transaction fetch and caches the new transactions
    func fetchTransactions() -> Single<[EthereumHistoricalTransaction]> {
        cachedTransactions.fetchValue
    }

    func transaction(identifier: String) -> Single<EthereumHistoricalTransaction> {
        Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<EthereumHistoricalTransaction> in
                self.client
                    .transaction(with: identifier)
                    .map { response in
                        EthereumHistoricalTransaction(
                            response: response,
                            accountAddress: tuple.0.accountAddress,
                            latestBlock: tuple.1
                        )
                    }
            }
    }

    // MARK: - Privately used accessors

    private func fetch() -> Single<[EthereumHistoricalTransaction]> {
        Single
            .zip(account, latestBlock)
            .flatMap(weak: self) { (self, tuple) -> Single<[EthereumHistoricalTransaction]> in
                self.fetch(account: tuple.0, latestBlock: tuple.1)
            }
    }

    private func fetch(account: EthereumAssetAccount, latestBlock: Int) -> Single<[EthereumHistoricalTransaction]> {
        client
            .transactions(for: account.accountAddress)
            .map(weak: self) { (self, response) -> [EthereumHistoricalTransaction] in
                self.transactions(
                    from: account.accountAddress,
                    latestBlock: latestBlock,
                    response: response
                )
            }
    }

    private func fetchLatestBlock() -> Single<Int> {
        client.latestBlock.map(\.number)
    }

    private func transactions(
        from address: String,
        latestBlock: Int,
        response: [EthereumHistoricalTransactionResponse]
    ) -> [EthereumHistoricalTransaction] {
        response
            .map { transactionResponse -> EthereumHistoricalTransaction in
                EthereumHistoricalTransaction(
                    response: transactionResponse,
                    accountAddress: address,
                    latestBlock: latestBlock
                )
            }
            // Sort backwards
            .sorted(by: >)
    }
}
