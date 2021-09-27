// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct OrderPriceTier {
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
    public static let zero = OrderPriceTier(volume: "0", price: "0", marginPrice: "0")
}
