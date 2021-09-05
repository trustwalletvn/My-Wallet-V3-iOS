// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class FiatBalanceCollectionViewInteractor {

    // MARK: - Types

    public typealias State = ValueCalculationState<[FiatCustodialBalanceViewInteractor]>

    // MARK: - Exposed Properties

    /// Streams the interactors
    public var interactorsState: Observable<State> {
        _ = setup
        return interactorsStateRelay.asObservable()
    }

    var interactors: Observable<[FiatCustodialBalanceViewInteractor]> {
        interactorsState
            .compactMap(\.value)
            .startWith([])
    }

    // MARK: - Injected Properties

    private let tiersService: KYCTiersServiceAPI
    private let tradingBalanceService: TradingBalanceServiceAPI
    private let paymentMethodsService: PaymentMethodsServiceAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let refreshRelay = PublishRelay<Void>()
    private let coincore: CoincoreAPI
    private let disposeBag = DisposeBag()

    // MARK: - Accessors

    let interactorsStateRelay = BehaviorRelay<State>(value: .invalid(.empty))

    private func fiatAccounts() -> Single<[SingleAccount]> {
        tiersService.tiers
            .map(\.isTier2Approved)
            .catchErrorJustReturn(false)
            .flatMap(weak: self) { (self, isTier2Approved) in
                guard isTier2Approved else {
                    return .just([])
                }
                return self.coincore.fiatAsset
                    .accountGroup(filter: .all)
                    .map(\.accounts)
            }
    }

    private lazy var setup: Void = {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                refreshRelay.asObservable()
            ) { (fiatCurrency: $0, _: $1) }
            .flatMapLatest(weak: self) { (self, data) in
                self.fiatAccounts()
                    .asObservable()
                    .map { accounts in
                        accounts
                            .sorted { $0.currencyType.code < $1.currencyType.code }
                            .sorted { lhs, _ -> Bool in lhs.currencyType.code == data.fiatCurrency.code }
                            .map(FiatCustodialBalanceViewInteractor.init(account:))
                    }
            }
            .map { .value($0) }
            .startWith(.calculating)
            .catchErrorJustReturn(.invalid(.empty))
            .bindAndCatch(to: interactorsStateRelay)
            .disposed(by: disposeBag)
    }()

    public init(
        tiersService: KYCTiersServiceAPI = resolve(),
        tradingBalanceService: TradingBalanceServiceAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve(),
        paymentMethodsService: PaymentMethodsServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI = resolve(),
        coincore: CoincoreAPI = resolve()
    ) {
        self.coincore = coincore
        self.tiersService = tiersService
        self.tradingBalanceService = tradingBalanceService
        self.paymentMethodsService = paymentMethodsService
        self.enabledCurrenciesService = enabledCurrenciesService
        self.fiatCurrencyService = fiatCurrencyService
    }

    public func refresh() {
        refreshRelay.accept(())
    }
}

extension FiatBalanceCollectionViewInteractor: Equatable {
    public static func == (lhs: FiatBalanceCollectionViewInteractor, rhs: FiatBalanceCollectionViewInteractor) -> Bool {
        lhs.interactorsStateRelay.value == rhs.interactorsStateRelay.value
    }
}

extension FiatBalanceCollectionViewInteractor: FiatBalancesInteracting {
    public var hasBalances: Observable<Bool> {
        interactorsState
            .compactMap(\.value)
            .map { $0.count > 0 }
            .catchErrorJustReturn(false)
    }

    public func reloadBalances() {
        refresh()
    }
}
