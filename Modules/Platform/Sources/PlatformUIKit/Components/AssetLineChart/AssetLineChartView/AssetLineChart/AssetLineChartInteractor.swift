// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift

public final class AssetLineChartInteractor: AssetLineChartInteracting {

    // MARK: - Properties

    public var state: Observable<AssetLineChart.State.Interaction> {
        _ = setup
        return stateRelay
            .asObservable()
    }

    private var window: Signal<PriceWindow> {
        priceWindowRelay
            .distinctUntilChanged()
            .asSignal(onErrorJustReturn: .day(.oneHour))
    }

    public let priceWindowRelay = PublishRelay<PriceWindow>()

    // MARK: - Private Accessors

    private lazy var setup: Void = {
        window.emit(onNext: { [weak self] priceWindow in
            guard let self = self else { return }
            self.loadHistoricalPrices(within: priceWindow)
        })
            .disposed(by: disposeBag)
    }()

    private let stateRelay = BehaviorRelay<AssetLineChart.State.Interaction>(value: .loading)
    private let cryptoCurrency: CryptoCurrency
    private let priceService: PriceServiceAPI
    private let fiatCurrencyService: FiatCurrencyServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        cryptoCurrency: CryptoCurrency,
        fiatCurrencyService: FiatCurrencyServiceAPI,
        priceService: PriceServiceAPI = resolve()
    ) {
        self.fiatCurrencyService = fiatCurrencyService
        self.priceService = priceService
        self.cryptoCurrency = cryptoCurrency
    }

    private func loadHistoricalPrices(within window: PriceWindow) {
        let cryptoCurrency = self.cryptoCurrency
        fiatCurrencyService
            .fiatCurrencyObservable
            .flatMap { [priceService] fiatCurrency in
                priceService
                    .priceSeries(of: cryptoCurrency, in: fiatCurrency, within: window)
                    .asObservable()
            }
            .map { .init(delta: $0.delta, currency: cryptoCurrency, prices: $0.prices) }
            .map { .loaded(next: $0) }
            .startWith(.loading)
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
