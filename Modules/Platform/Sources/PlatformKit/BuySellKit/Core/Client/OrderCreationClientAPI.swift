// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol OrderCreationClientAPI: AnyObject {

    /// Creates a buy order using the given data
    func create(
        order: OrderPayload.Request,
        createPendingOrder: Bool
    ) -> AnyPublisher<OrderPayload.Response, NabuNetworkError>
}
