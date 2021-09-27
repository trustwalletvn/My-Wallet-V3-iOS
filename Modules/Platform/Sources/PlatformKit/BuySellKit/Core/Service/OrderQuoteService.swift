// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol OrderQuoteServiceAPI: AnyObject {

    func getQuote(
        for action: Order.Action,
        cryptoCurrency: CryptoCurrency,
        fiatValue: FiatValue
    ) -> Single<Quote>
}

final class OrderQuoteService: OrderQuoteServiceAPI {

    // MARK: - Properties

    private let client: QuoteClientAPI

    // MARK: - Setup

    init(client: QuoteClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - API

    func getQuote(
        for action: Order.Action,
        cryptoCurrency: CryptoCurrency,
        fiatValue: FiatValue
    ) -> Single<Quote> {
        client.getQuote(
            for: action,
            to: cryptoCurrency,
            amount: fiatValue
        )
        .asSingle()
        .map {
            try Quote(
                to: cryptoCurrency,
                amount: fiatValue,
                response: $0
            )
        }
    }
}
