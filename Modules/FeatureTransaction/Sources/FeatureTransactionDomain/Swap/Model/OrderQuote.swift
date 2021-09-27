// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrderQuote {
    public let pair: OrderPair
    public let priceTiers: [OrderPriceTier]

    public init(
        pair: OrderPair,
        priceTiers: [OrderPriceTier]
    ) {
        self.pair = pair
        self.priceTiers = priceTiers
    }
}
