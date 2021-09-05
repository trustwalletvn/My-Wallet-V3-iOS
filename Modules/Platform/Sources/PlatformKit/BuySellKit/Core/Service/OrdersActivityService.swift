// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

final class OrdersActivityService: OrdersActivityServiceAPI {

    private let client: OrdersActivityClientAPI
    private let enabledCurrenciesService: EnabledCurrenciesServiceAPI
    private let cache: Cache<CurrencyType, OrdersActivityResponse>

    init(
        client: OrdersActivityClientAPI = resolve(),
        enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()
    ) {
        self.client = client
        self.enabledCurrenciesService = enabledCurrenciesService
        cache = Cache(entryLifetime: 90)
    }

    func activity(fiatCurrency: FiatCurrency) -> Single<[CustodialActivityEvent.Fiat]> {
        guard let response = cache.value(forKey: fiatCurrency.currency) else {
            return client.activityResponse(currency: fiatCurrency)
                .do(onSuccess: { [cache] response in
                    cache.set(response, forKey: fiatCurrency.currency)
                })
                .map { response in
                    response.items.compactMap(CustodialActivityEvent.Fiat.init)
                }
        }
        return .just(response.items.compactMap(CustodialActivityEvent.Fiat.init))
    }

    func activity(cryptoCurrency: CryptoCurrency) -> Single<[CustodialActivityEvent.Crypto]> {
        guard let response = cache.value(forKey: cryptoCurrency.currency) else {
            return client.activityResponse(currency: cryptoCurrency)
                .do(onSuccess: { [cache] response in
                    cache.set(response, forKey: cryptoCurrency.currency)
                })
                .map { [enabledCurrenciesService] response in
                    response.items.compactMap { item in
                        CustodialActivityEvent.Crypto(item: item, enabledCurrenciesService: enabledCurrenciesService)
                    }
                }
        }
        let activity = response.items.compactMap { item in
            CustodialActivityEvent.Crypto(item: item, enabledCurrenciesService: enabledCurrenciesService)
        }
        return .just(activity)
    }
}
