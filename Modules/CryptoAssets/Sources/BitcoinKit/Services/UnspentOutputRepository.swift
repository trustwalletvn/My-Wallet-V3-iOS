// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinChainKit
import DIKit
import PlatformKit
import RxSwift
import ToolKit

protocol UnspentOutputRepositoryAPI {
    var unspentOutputs: Single<UnspentOutputs> { get }
    var fetchUnspentOutputs: Single<UnspentOutputs> { get }
}

final class UnspentOutputRepository: UnspentOutputRepositoryAPI {

    // MARK: - Properties

    var unspentOutputs: Single<UnspentOutputs> {
        cachedUnspentOutputs.valueSingle
    }

    var fetchUnspentOutputs: Single<UnspentOutputs> {
        cachedUnspentOutputs.fetchValue
    }

    // MARK: - Private properties

    private let bridge: BitcoinWalletBridgeAPI
    private let client: APIClientAPI
    private let cachedUnspentOutputs: CachedValue<UnspentOutputs>

    // MARK: - Init

    init(
        with bridge: BitcoinWalletBridgeAPI = resolve(),
        client: APIClientAPI = resolve(),
        scheduler: SchedulerType = CachedValueConfiguration.generateScheduler()
    ) {
        self.bridge = bridge
        self.client = client

        cachedUnspentOutputs = CachedValue<UnspentOutputs>(
            configuration: .periodic(10, scheduler: scheduler)
        )

        cachedUnspentOutputs.setFetch { [weak self] () -> Single<UnspentOutputs> in
            guard let self = self else {
                return Single.error(ToolKitError.nullReference(Self.self))
            }
            return self.fetchAllUnspentOutputs()
        }
    }

    // MARK: - Private methods

    private func fetchAllUnspentOutputs() -> Single<UnspentOutputs> {
        bridge.wallets
            .map { wallets -> [XPub] in
                wallets
                    .map(\.publicKeys.xpubs)
                    .flatMap { $0 }
            }
            .flatMap(weak: self) { (self, addresses) -> Single<UnspentOutputs> in
                self.fetchUnspentOutputs(for: addresses)
            }
    }

    private func fetchUnspentOutputs(for addresses: [XPub]) -> Single<UnspentOutputs> {
        client.unspentOutputs(for: addresses)
            .map { UnspentOutputs(networkResponse: $0) }
    }
}
