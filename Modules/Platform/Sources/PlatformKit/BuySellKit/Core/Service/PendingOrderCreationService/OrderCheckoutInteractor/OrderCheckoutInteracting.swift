// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol OrderCheckoutInteracting: AnyObject {
    func prepare(using checkoutData: CheckoutData) -> Single<(interactionData: CheckoutInteractionData, checkoutData: CheckoutData)>
    func prepare(using order: OrderDetails) -> Single<CheckoutInteractionData>
}
