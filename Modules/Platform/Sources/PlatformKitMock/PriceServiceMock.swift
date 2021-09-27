// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import PlatformKit

final class PriceServiceMock: PriceServiceAPI {
    var moneyValuePair: MoneyValuePair!
    var historicalPriceSeries: HistoricalPriceSeries!
    var priceQuoteAtTime: PriceQuoteAtTime!

    func moneyValuePair(
        fiatValue: FiatValue,
        cryptoCurrency: CryptoCurrency,
        usesFiatAsBase: Bool
    ) -> AnyPublisher<MoneyValuePair, NetworkError> {
        .just(moneyValuePair)
    }

    func price(of baseCurrency: Currency, in quoteCurrency: Currency) -> AnyPublisher<PriceQuoteAtTime, NetworkError> {
        .just(priceQuoteAtTime)
    }

    func price(of baseCurrency: Currency, in quoteCurrency: Currency, at date: Date?) -> AnyPublisher<PriceQuoteAtTime, NetworkError> {
        .just(priceQuoteAtTime)
    }

    func priceSeries(
        of baseCurrency: CryptoCurrency,
        in quoteCurrency: FiatCurrency,
        within window: PriceWindow
    ) -> AnyPublisher<HistoricalPriceSeries, NetworkError> {
        .just(historicalPriceSeries)
    }
}
