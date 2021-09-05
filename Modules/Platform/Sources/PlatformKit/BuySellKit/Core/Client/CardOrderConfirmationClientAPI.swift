// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol CardOrderConfirmationClientAPI: AnyObject {

    /// Confirm an order
    func confirmOrder(
        with identifier: String,
        partner: OrderPayload.ConfirmOrder.Partner,
        paymentMethodId: String?
    ) -> Single<OrderPayload.Response>
}
