// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol OrderCancellationClientAPI: AnyObject {
    /// Cancels an order with a given identifier
    func cancel(order id: String) -> Completable
}
