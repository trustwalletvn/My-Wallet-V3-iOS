// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit
import RxSwift
import ToolKit

final class PricesInterpolator {

    private let prices: [OrderPriceTier]

    init(prices: [OrderPriceTier]) {
        self.prices = [.zero] + prices
    }

    func rate(amount: BigInt) -> BigInt {
        prices
            .enumerated()
            .compactMap { index, priceTier -> BigInt? in
                guard index != prices.count - 1 else {
                    return BigInt(stringLiteral: priceTier.price)
                }

                let next = prices[index + 1]
                let volume = BigInt(stringLiteral: priceTier.volume)
                let price = BigInt(stringLiteral: priceTier.price)
                let nextVolume = BigInt(stringLiteral: next.volume)
                let nextPrice = BigInt(stringLiteral: next.price)

                if volume < amount, amount <= nextVolume {
                    return LinearInterpolator
                        .interpolate(
                            x: [volume, nextVolume],
                            y: [price, nextPrice],
                            xi: amount
                        )
                } else {
                    return nil
                }
            }
            .first ?? .zero
    }
}
