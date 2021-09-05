// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import RxRelay
import RxSwift
import ToolKit

public protocol OrdersServiceAPI: AnyObject {

    /// Streams all cached Simple Buy orders from cache, or fetch from
    /// remote if they are not cached
    var orders: Single<[OrderDetails]> { get }

    /// Fetches the orders from remote
    func fetchOrders() -> Single<[OrderDetails]>

    /// Fetches the order for a given identifier
    func fetchOrder(with identifier: String) -> Single<OrderDetails>
}

final class OrdersService: OrdersServiceAPI {

    // MARK: - Service Error

    enum ServiceError: Error {
        case mappingError
    }

    // MARK: - Exposed

    var orders: Single<[OrderDetails]> {
        ordersCachedValue.valueSingle
    }

    private let ordersCachedValue = CachedValue<[OrderDetails]>(
        configuration: .periodic(60)
    )

    // MARK: - Injected

    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let client: OrderDetailsClientAPI

    // MARK: - Setup

    init(
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        client: OrderDetailsClientAPI = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.client = client
        ordersCachedValue.setFetch { [client, analyticsRecorder] in
            client.orderDetails(pendingOnly: false)
                .map { orders in
                    orders.compactMap {
                        OrderDetails(recorder: analyticsRecorder, response: $0)
                    }
                }
        }
    }

    func fetchOrders() -> Single<[OrderDetails]> {
        ordersCachedValue.fetchValue
    }

    func fetchOrder(with identifier: String) -> Single<OrderDetails> {
        client.orderDetails(with: identifier)
            .map { [analyticsRecorder] response in
                OrderDetails(recorder: analyticsRecorder, response: response)
            }
            .onNil(error: ServiceError.mappingError)
    }
}
