// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

final class TradeLimitsService: TradeLimitsAPI {

    private let disposables = CompositeDisposable()

    private var cachedLimits = BehaviorRelay<TradeLimits?>(value: nil)
    private var cachedLimitsTimer: Timer?
    private let clearCachedLimitsInterval: TimeInterval = 60
    private let networkAdapter: NetworkAdapterAPI

    init(networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail)) {
        self.networkAdapter = networkAdapter
        cachedLimitsTimer = Timer.scheduledTimer(
            withTimeInterval: clearCachedLimitsInterval,
            repeats: true
        ) { [weak self] _ in
            self?.clearCachedLimits()
        }
        cachedLimitsTimer?.tolerance = clearCachedLimitsInterval / 10
        cachedLimitsTimer?.fire()
    }

    deinit {
        cachedLimitsTimer?.invalidate()
        cachedLimitsTimer = nil
        disposables.dispose()
    }

    enum TradeLimitsAPIError: Error {
        case generic
    }

    /// Initializes this TradeLimitsService so that the trade limits for the current
    /// user is pre-fetched and cached
    func initialize(withFiatCurrency currency: String) {
        let disposable = getTradeLimits(withFiatCurrency: currency, ignoringCache: false)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { _ in
                Logger.shared.debug("Successfully initialized TradeLimitsService.")
            }, onError: { error in
                Logger.shared.error("Failed to initialize TradeLimitsService: \(error)")
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(
        withFiatCurrency currency: String,
        withCompletion: @escaping ((Result<TradeLimits, Error>) -> Void)
    ) {
        let disposable = getTradeLimits(withFiatCurrency: currency, ignoringCache: false)
            .subscribeOn(MainScheduler.asyncInstance)
            .observeOn(MainScheduler.instance)
            .subscribe(onSuccess: { payload in
                withCompletion(.success(payload))
            }, onError: { error in
                withCompletion(.failure(error))
            })
        _ = disposables.insert(disposable)
    }

    func getTradeLimits(withFiatCurrency currency: String, ignoringCache: Bool) -> Single<TradeLimits> {
        Single.deferred { [unowned self] in
            guard let cachedLimits = self.cachedLimits.value,
                  cachedLimits.currency == currency,
                  ignoringCache == false
            else {
                return self.getTradeLimitsNetwork(withFiatCurrency: currency)
            }
            return Single.just(cachedLimits)
        }
        .do(onSuccess: { [weak self] response in
            self?.cachedLimits.accept(response)
        })
    }

    // MARK: - Private

    private func getTradeLimitsNetwork(withFiatCurrency currency: String) -> Single<TradeLimits> {
        guard let baseURL = URL(
            string: BlockchainAPI.shared.retailCoreUrl
        ) else {
            return .error(TradeLimitsAPIError.generic)
        }

        guard let endpoint = URL.endpoint(
            baseURL,
            pathComponents: ["trades", "limits"],
            queryParameters: ["currency": currency]
        ) else {
            return .error(TradeLimitsAPIError.generic)
        }
        return networkAdapter
            .perform(
                request: NetworkRequest(
                    endpoint: endpoint,
                    method: .get,
                    authenticated: true
                ),
                errorResponseType: NabuNetworkError.self
            )
    }

    private func clearCachedLimits() {
        cachedLimits = BehaviorRelay<TradeLimits?>(value: nil)
    }
}
