// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

/// This protocol defines a `Single<FiatValue>`. It's the
/// latest Fiat price for a given asset type and is to be used
/// with the `HistoricalPricesAPI`. Basically it's the last item
/// in the array of prices returned.
public protocol LatestFiatPriceFetching: AnyObject {
    var latestPrice: Observable<FiatValue> { get }
}

public protocol HistoricalFiatPriceServiceAPI: LatestFiatPriceFetching {

    /// The calculationState of the service. Returns a `ValueCalculationState` that
    /// contains `HistoricalPriceSeries` and a `FiatValue` each derived from `LatestFiatPriceFetching`
    /// and `HistoricalFiatPriceFetching`.
    var calculationState: Observable<ValueCalculationState<HistoricalFiatPriceResponse>> { get }
    /// A trigger that force the service to fetch the updated price.
    /// Handy to call on currency type and value changes
    var fetchTriggerRelay: PublishRelay<PriceWindow> { get }
}

public final class HistoricalFiatPriceService: HistoricalFiatPriceServiceAPI {

    // MARK: Types

    public typealias CalculationState = ValueCalculationState<HistoricalFiatPriceResponse>

    // MARK: - HistoricalFiatPriceServiceAPI

    public let fetchTriggerRelay = PublishRelay<PriceWindow>()

    public var calculationState: Observable<CalculationState> {
        _ = setup
        return calculationStateRelay.asObservable()
    }

    // MARK: - LatestFiatPriceFetching

    public var latestPrice: Observable<FiatValue> {
        exchangeAPI.fiatPrice
    }

    // MARK: - Private Properties

    private let calculationStateRelay = BehaviorRelay<CalculationState>(value: .calculating)
    private let bag = DisposeBag()

    // MARK: - Services

    /// The historical price service
    private let priceService: PriceServiceAPI

    /// The exchange service
    private let exchangeAPI: PairExchangeServiceAPI

    /// The currency service
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    /// The associated asset
    private let cryptoCurrency: CryptoCurrency

    private lazy var setup: Void = {
        let scheduler = ConcurrentDispatchQueueScheduler(qos: .background)

        let historicalPrices = Observable
            .combineLatest(fiatCurrencyService.fiatCurrencyObservable, fetchTriggerRelay)
            .throttle(.milliseconds(100), scheduler: scheduler)
            .map { ($0.0, $0.1) }
            .flatMapLatest(weak: self) { (self, tuple) -> Observable<(HistoricalPriceSeries, String, PriceWindow)> in
                let fiatCurrency = tuple.0
                let window = tuple.1
                let prices = self.priceService.priceSeries(
                    of: self.cryptoCurrency,
                    in: fiatCurrency,
                    within: window
                )
                .asObservable()
                return Observable.zip(prices, Observable.just(fiatCurrency.code), Observable.just(window))
            }
            .map { ($0.0, $0.2) }
            .subscribeOn(scheduler)
            .observeOn(scheduler)
            .share(replay: 1)

        Observable
            .combineLatest(latestPrice, historicalPrices)
            .map {
                .value(HistoricalFiatPriceResponse(prices: $0.1.0, fiatValue: $0.0, priceWindow: $0.1.1))
            }
            .startWith(.calculating)
            .catchErrorJustReturn(.calculating)
            .bindAndCatch(to: calculationStateRelay)
            .disposed(by: bag)
    }()

    public init(
        cryptoCurrency: CryptoCurrency,
        exchangeAPI: PairExchangeServiceAPI,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.exchangeAPI = exchangeAPI
        self.cryptoCurrency = cryptoCurrency
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
    }
}
