// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol OrdersActivityClientAPI: AnyObject {

    /// Fetch order activity response
    func activityResponse(currency: Currency) -> Single<OrdersActivityResponse>
}
