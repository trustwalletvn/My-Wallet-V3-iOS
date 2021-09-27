// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift

public protocol PairExchangeServiceAPI: AnyObject {

    /// The current fiat exchange price.
    /// The implementer should implement this as a `.shared(replay: 1)`
    /// resource for efficiency among multiple clients.
    var fiatPrice: Observable<FiatValue> { get }

    /// A trigger that force the service to fetch the updated price.
    /// Handy to call on currency type and value changes
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public final class PairExchangeService: PairExchangeServiceAPI {

    // TODO: Network failure

    /// Fetches the fiat price, and shares its stream with other
    /// subscribers to keep external API usage count in check.
    /// Also handles currency code change
    public private(set) lazy var fiatPrice: Observable<FiatValue> = {
        Observable
            .combineLatest(
                fiatCurrencyService.fiatCurrencyObservable,
                fetchTriggerRelay.asObservable().startWith(())
            )
            .throttle(.milliseconds(250), scheduler: ConcurrentDispatchQueueScheduler(qos: .background))
            .map(\.0)
            .flatMapLatest(weak: self) { (self, fiatCurrency) -> Observable<PriceQuoteAtTime> in
                self.priceService
                    .price(of: self.currency, in: fiatCurrency)
                    .asSingle()
                    .catchErrorJustReturn(
                        PriceQuoteAtTime(
                            timestamp: Date(),
                            moneyValue: .zero(currency: fiatCurrency)
                        )
                    )
                    .asObservable()
            }
            // There MUST be a fiat value here
            .map { $0.moneyValue.fiatValue! }
            .catchError(weak: self) { (self, _) -> Observable<FiatValue> in
                self.zero
            }
            .distinctUntilChanged()
            .share(replay: 1)
    }()

    private var zero: Observable<FiatValue> {
        fiatCurrencyService
            .fiatCurrencyObservable
            .map { FiatValue.zero(currency: $0) }
    }

    /// A trigger for a fetch
    public let fetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Services

    /// The exchange service
    private let priceService: PriceServiceAPI

    /// The currency service
    private let fiatCurrencyService: FiatCurrencyServiceAPI

    /// The associated currency
    private let currency: Currency

    // MARK: - Setup

    public init(
        currency: Currency,
        priceService: PriceServiceAPI = resolve(),
        fiatCurrencyService: FiatCurrencyServiceAPI
    ) {
        self.currency = currency
        self.priceService = priceService
        self.fiatCurrencyService = fiatCurrencyService
    }
}
