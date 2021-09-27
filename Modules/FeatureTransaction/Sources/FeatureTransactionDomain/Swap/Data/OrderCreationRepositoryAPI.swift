// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol OrderCreationRepositoryAPI {

    func createOrder(
        direction: OrderDirection,
        quoteIdentifier: String,
        volume: MoneyValue,
        destinationAddress: String?,
        refundAddress: String?
    ) -> AnyPublisher<SwapOrder, NabuNetworkError>
}

public protocol OrderUpdateRepositoryAPI {

    func updateOrder(
        identifier: String,
        success: Bool
    ) -> AnyPublisher<Void, NabuNetworkError>
}
