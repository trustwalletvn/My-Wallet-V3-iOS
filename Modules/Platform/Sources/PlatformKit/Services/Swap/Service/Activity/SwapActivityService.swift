// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol SwapActivityServiceAPI: AnyObject {
    func fetchActivity(cryptoCurrency: CryptoCurrency, directions: Set<OrderDirection>) -> Single<[SwapActivityItemEvent]>
}

final class SwapActivityService: SwapActivityServiceAPI {

    private let client: SwapClientAPI
    private let fiatCurrencyProvider: FiatCurrencySettingsServiceAPI
    private let cache: CachedValue<[SwapActivityItemEvent]>

    init(
        client: SwapClientAPI = resolve(),
        fiatCurrencyProvider: CompleteSettingsServiceAPI = resolve()
    ) {
        self.fiatCurrencyProvider = fiatCurrencyProvider
        self.client = client
        cache = .init(configuration: .periodic(30))
        cache.setFetch {
            fiatCurrencyProvider.fiatCurrency
                .flatMap { fiatCurrency -> Single<[SwapActivityItemEvent]> in
                    client.fetchActivity(
                        from: Date(),
                        fiatCurrency: fiatCurrency.code,
                        cryptoCurrency: nil,
                        limit: 50
                    )
                    .asSingle()
                }
        }
    }

    func fetchActivity(
        cryptoCurrency: CryptoCurrency,
        directions: Set<OrderDirection>
    ) -> Single<[SwapActivityItemEvent]> {
        cache.valueSingle
            .map { events in
                events
                    .filter { event in
                        directions.contains(event.kind.direction)
                            && event.pair.inputCurrencyType == cryptoCurrency
                    }
            }
    }
}
