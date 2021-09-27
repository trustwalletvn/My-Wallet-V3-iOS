// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain

public struct OrderPriceTierResponse: Decodable {
    public let volume: String
    public let price: String
    public let marginPrice: String

    public init(volume: String, price: String, marginPrice: String) {
        self.volume = volume
        self.price = price
        self.marginPrice = marginPrice
    }
}

extension OrderPriceTier {

    init(response: OrderPriceTierResponse) {
        self.init(
            volume: response.volume,
            price: response.price,
            marginPrice: response.marginPrice
        )
    }
}
