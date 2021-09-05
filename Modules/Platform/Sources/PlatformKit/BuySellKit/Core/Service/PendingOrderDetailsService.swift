// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol PendingOrderDetailsServiceAPI: AnyObject {
    var pendingOrderDetails: Single<OrderDetails?> { get }
    var pendingActionOrderDetails: Single<OrderDetails?> { get }

    func cancel() -> Completable
}

final class PendingOrderDetailsService: PendingOrderDetailsServiceAPI {

    var pendingOrderDetails: Single<OrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter { $0.isAwaitingAction || $0.is3DSConfirmedCardOrder }
            }
            .map(\.first)
    }

    var pendingActionOrderDetails: Single<OrderDetails?> {
        ordersService.fetchOrders()
            .map { orders in
                orders
                    .filter { !$0.isFinal }
                    .filter(\.isAwaitingAction)
            }
            .map(\.first)
    }

    // MARK: - Injected

    private let ordersService: OrdersServiceAPI
    private let cancallationService: OrderCancellationServiceAPI

    // MARK: - Setup

    init(
        ordersService: OrdersServiceAPI = resolve(),
        cancallationService: OrderCancellationServiceAPI = resolve()
    ) {
        self.ordersService = ordersService
        self.cancallationService = cancallationService
    }

    func cancel() -> Completable {
        pendingOrderDetails
            .flatMapCompletable(weak: self) { (self, details) -> Completable in
                guard let details = details else { return .empty() }
                return self.cancallationService.cancel(order: details.identifier)
            }
    }
}
