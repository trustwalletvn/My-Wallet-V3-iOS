// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CardAdditionClientAPI: AnyObject {
    func add(
        for currency: String,
        email: String,
        billingAddress: CardPayload.BillingAddress
    ) -> Single<CardPayload>
}
