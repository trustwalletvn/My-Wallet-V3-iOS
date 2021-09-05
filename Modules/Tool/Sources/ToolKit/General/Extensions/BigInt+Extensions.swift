// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

extension BigInt {
    public static let one = BigInt(1)
    public static let zero = BigInt(0)
}

extension BigUInt {
    public static let zero = BigUInt(0)
}

extension BigUInt {
    /// Even-length hexadecimal string representation of this element.
    public var hexString: String {
        let string = String(self, radix: 16)
        // Check odd length hex string
        if string.count % 2 != 0 {
            return "0" + string
        }
        return string
    }
}

extension BigInt {

    public func decimalDivision(divisor: BigInt) -> Decimal {
        let (quotient, remainder) = quotientAndRemainder(dividingBy: divisor)
        return Decimal(string: String(quotient))!
            + (Decimal(string: String(remainder))! / Decimal(string: String(divisor))!)
    }

    /// Assuming `self` is a minor value. Converting it to major.
    /// Note that doing so may cause the returned value to lose precision,
    /// therefore we should avoid using it for anything other than to display data.
    /// - Parameters:
    ///   - baseDecimalPlaces: Number of the decimal places of the represented value currency used to convert minor to major value.
    ///   - roundingDecimalPlaces: Number of the decimal places used to round value.
    /// - Returns: A major value (Decimal)
    public func toDecimalMajor(
        baseDecimalPlaces: Int,
        roundingDecimalPlaces: Int,
        roundingMode: Decimal.RoundingMode = .bankers
    ) -> Decimal {
        let divisor = BigInt(10).power(baseDecimalPlaces)
        let majorValue = decimalDivision(divisor: divisor)
        return majorValue.roundTo(places: roundingDecimalPlaces, roundingMode: roundingMode)
    }

    public func toMinor(maxDecimalPlaces: Int) -> BigInt {
        let minorDecimal = self * BigInt(10).power(maxDecimalPlaces)
        return minorDecimal
    }
}
