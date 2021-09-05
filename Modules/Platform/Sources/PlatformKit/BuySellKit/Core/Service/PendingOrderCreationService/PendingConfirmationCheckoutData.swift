// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct PendingConfirmationCheckoutData {
    public let quote: Quote
    public let checkoutData: CheckoutData

    func data(byAppending checkoutData: CheckoutData) -> PendingConfirmationCheckoutData {
        .init(quote: quote, checkoutData: checkoutData)
    }

    init(quote: Quote, checkoutData: CheckoutData) {
        self.quote = quote
        self.checkoutData = checkoutData
    }
}
