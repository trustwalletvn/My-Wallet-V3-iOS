// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol CardAdditionClientAPI: AnyObject {

    func add(
        for currency: String,
        email: String,
        billingAddress: CardPayload.BillingAddress
    ) -> AnyPublisher<CardPayload, NabuNetworkError>
}
