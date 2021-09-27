// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol TransactionLimitsRepositoryAPI {

    func fetchTransactionLimits(
        currency: CurrencyType,
        networkFee: CurrencyType,
        product: TransactionLimitsProduct
    ) -> AnyPublisher<TransactionLimits, NabuNetworkError>
}
