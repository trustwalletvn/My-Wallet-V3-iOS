// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol OrderQuoteRepositoryAPI: AnyObject {

    func fetchQuote(
        direction: OrderDirection,
        sourceCurrencyType: CurrencyType,
        destinationCurrencyType: CurrencyType
    ) -> AnyPublisher<OrderQuotePayload, NabuNetworkError>
}
