// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import PlatformKit
import RxSwift
import ToolKit

public protocol EthereumAccountDetailsServiceAPI {

    /// Streams the default account details.
    func accountDetails() -> Single<EthereumAssetAccountDetails>
}

class EthereumAccountDetailsService: EthereumAccountDetailsServiceAPI {

    // MARK: - Properties

    private let bridge: EthereumWalletBridgeAPI
    private let client: BalanceClientAPI
    private let cache: CachedValue<EthereumAssetAccountDetails>

    // MARK: - Setup

    init(
        with bridge: EthereumWalletBridgeAPI = resolve(),
        client: BalanceClientAPI = resolve(),
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) {
        self.bridge = bridge
        self.client = client
        cache = .init(configuration: .periodic(30, scheduler: scheduler))
        cache.setFetch(weak: self) { (self) -> Single<EthereumAssetAccountDetails> in
            self.fetchAccountDetails()
        }
    }

    func accountDetails() -> Single<EthereumAssetAccountDetails> {
        cache.valueSingle
    }

    private func fetchAccountDetails() -> Single<EthereumAssetAccountDetails> {
        bridge.account
            .flatMap(weak: self) { (self, account) -> Single<EthereumAssetAccountDetails> in
                self.client.balanceDetails(from: account.accountAddress)
                    .map { details in
                        EthereumAssetAccountDetails(
                            account: account,
                            balance: details.cryptoValue,
                            nonce: details.nonce
                        )
                    }
            }
    }
}
