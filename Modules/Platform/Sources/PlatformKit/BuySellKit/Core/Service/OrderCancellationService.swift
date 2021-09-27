// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift

public protocol OrderCancellationServiceAPI: AnyObject {

    /// Cancels an order associated with the given id
    func cancel(order id: String) -> Completable
}

final class OrderCancellationService: OrderCancellationServiceAPI {

    // MARK: - Injected

    private let client: OrderCancellationClientAPI
    private let orderDetailsService: OrdersServiceAPI

    // MARK: - Setup

    init(
        client: OrderCancellationClientAPI = resolve(),
        orderDetailsService: OrdersServiceAPI = resolve()
    ) {
        self.client = client
        self.orderDetailsService = orderDetailsService
    }

    // MARK: - Exposed

    func cancel(order id: String) -> Completable {
        // Cancel the order
        client.cancel(order: id)
            .asObservable()
            .ignoreElements()
            // Fetch the orders anew
            .andThen(orderDetailsService.fetchOrders())
            .asCompletable()
    }
}
