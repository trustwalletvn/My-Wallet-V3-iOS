// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public protocol StellarConfigurationAPI {
    var configuration: Single<StellarConfiguration> { get }
}

final class StellarConfigurationService: StellarConfigurationAPI {

    // MARK: Private Static Properties

    private static let refreshInterval: TimeInterval = 60.0 * 60.0 // 1h

    var configuration: Single<StellarConfiguration> {
        Single.deferred { [unowned self] in
            guard let cachedValue = self.cachedConfiguration.value, !self.shouldRefresh else {
                return self.fetchConfiguration
            }
            return Single.just(cachedValue)
        }
    }

    // MARK: Private Properties

    private var cachedConfiguration = BehaviorRelay<StellarConfiguration?>(value: nil)

    private var fetchConfiguration: Single<StellarConfiguration> {
        bridgeAPI.stellarConfigurationDomain
            .map { domain -> StellarConfiguration in
                guard let stellarHorizon = domain else {
                    return StellarConfiguration.Blockchain.production
                }
                return StellarConfiguration(horizonURL: stellarHorizon)
            }
            .do(onSuccess: { [weak self] _ in
                self?.lastRefresh = Date()
            })
            .catchErrorJustReturn(StellarConfiguration.Blockchain.production)
            .do(onSuccess: { [weak self] configuration in
                self?.cachedConfiguration.accept(configuration)
            })
    }

    private var shouldRefresh: Bool {
        let lastRefreshInterval = Date(timeIntervalSinceNow: -StellarConfigurationService.refreshInterval)
        return lastRefresh.compare(lastRefreshInterval) == .orderedAscending
    }

    private var lastRefresh = Date(timeIntervalSinceNow: -StellarConfigurationService.refreshInterval)

    private let bridgeAPI: StellarWalletOptionsBridgeAPI

    init(bridge: StellarWalletOptionsBridgeAPI = resolve()) {
        bridgeAPI = bridge
    }
}
