// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol OrderDetailsClientAPI: AnyObject {

    /// Fetch all Buy/Sell orders
    func orderDetails(pendingOnly: Bool) -> Single<[OrderPayload.Response]>

    /// Fetch a single Buy/Sell order
    func orderDetails(with identifier: String) -> Single<OrderPayload.Response>
}
