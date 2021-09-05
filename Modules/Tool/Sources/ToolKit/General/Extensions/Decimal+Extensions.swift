// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Decimal {

    public var doubleValue: Double {
        (self as NSDecimalNumber).doubleValue
    }

    public func roundTo(places: Int, roundingMode: RoundingMode = .bankers) -> Decimal {
        let roundingBehaviour = NSDecimalNumberHandler(
            roundingMode: roundingMode,
            scale: Int16(places),
            raiseOnExactness: true,
            raiseOnOverflow: true,
            raiseOnUnderflow: true,
            raiseOnDivideByZero: true
        )
        let rounded = (self as NSDecimalNumber)
            .rounding(accordingToBehavior: roundingBehaviour)
        return rounded as Decimal
    }
}
