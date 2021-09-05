// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public typealias PolledOrder = PollResult<OrderDetails>

public protocol PendingOrderCompletionServiceAPI {
    func waitForFinalizedState(of orderId: String) -> Single<PolledOrder>
}

final class PendingOrderCompletionService: PendingOrderCompletionServiceAPI {

    // MARK: - Types

    private enum Constant {
        /// Duration in seconds
        static let pollingDuration: TimeInterval = 60
    }

    private let pollService: PollService<OrderDetails>
    private let ordersService: OrdersServiceAPI

    // MARK: - Setup

    init(ordersService: OrdersServiceAPI = resolve()) {
        self.ordersService = ordersService
        pollService = .init(matcher: { $0.isFinal })
    }

    func waitForFinalizedState(of orderId: String) -> Single<PolledOrder> {
        pollService.setFetch(weak: self) { (self) in
            self.ordersService
                .fetchOrder(with: orderId)
        }
        return pollService.poll(timeoutAfter: Constant.pollingDuration)
    }
}
