// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public protocol MoneyOperating: MoneyImplementing {

    static func max(_ x: Self, _ y: Self) throws -> Self

    static func min(_ x: Self, _ y: Self) throws -> Self
}

public struct MoneyValueComparisonError: Error {
    let currencyType1: CurrencyType
    let currencyType2: CurrencyType

    public init(currencyType1: CurrencyType, currencyType2: CurrencyType) {
        self.currencyType1 = currencyType1
        self.currencyType2 = currencyType2
    }
}

extension MoneyOperating {

    public static func max(_ x: Self, _ y: Self) throws -> Self {
        try ensureComparable(value: x, other: y)
        return try x > y ? x : y
    }

    public static func min(_ x: Self, _ y: Self) throws -> Self {
        try ensureComparable(value: x, other: y)
        return try x < y ? x : y
    }

    public static func > (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount > rhs.amount
    }

    public static func < (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount < rhs.amount
    }

    public static func >= (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount >= rhs.amount
    }

    public static func <= (lhs: Self, rhs: Self) throws -> Bool {
        try ensureComparable(value: lhs, other: rhs)
        return lhs.amount <= rhs.amount
    }

    public static func + (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        return Self(amount: lhs.amount + rhs.amount, currency: lhs.currencyType)
    }

    public static func - (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        return Self(amount: lhs.amount - rhs.amount, currency: lhs.currencyType)
    }

    public static func * (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        let amount = (lhs.amount * rhs.amount)
            .quotientAndRemainder(dividingBy: BigInt(10 ^^ lhs.maxDecimalPlaces))
            .quotient
        return Self(amount: amount, currency: lhs.currencyType)
    }

    /// Calculates the value of `self` before a given percentage change happened.
    /// e.g. if the current value is `11` and the percentage of change is `0.1` (`10%`)
    /// the return value will be `10`.
    public func value(before percentageChange: Double) -> Self {
        let percentageChange = percentageChange + 1
        guard !percentageChange.isNaN else {
            return Self.zero(currency: currencyType)
        }
        guard !percentageChange.isZero else {
            return Self.zero(currency: currencyType)
        }
        guard percentageChange.isNormal else {
            return Self.zero(currency: currencyType)
        }
        let decimalChange = Decimal(percentageChange)
        let majorAmount = displayMajorValue / decimalChange
        return Self.create(major: majorAmount, currency: currencyType)
    }

    /// - Returns: A` Decimal` rounded to 4 decimal places.
    public func percentage(of rhs: Self) throws -> Decimal {
        try Self.percentage(lhs: self, rhs: rhs)
    }

    private static func percentage(lhs: Self, rhs: Self) throws -> Decimal {
        try ensureComparable(value: lhs, other: rhs)
        let lhsDecimal = lhs.displayMajorValue
        let rhsDecimal = rhs.displayMajorValue
        let resDecimal = lhsDecimal / rhsDecimal
        return resDecimal.roundTo(places: 4)
    }

    public static func / (lhs: Self, rhs: Self) throws -> Self {
        try ensureComparable(value: lhs, other: rhs)
        let maxDecimalPlaces = lhs.maxDecimalPlaces
        let quotientAndRemainder = lhs.amount.quotientAndRemainder(dividingBy: rhs.amount)
        let quotientResult = quotientAndRemainder.quotient * BigInt(10 ^^ maxDecimalPlaces)
        let remainderDivisor = rhs.amount / BigInt(10 ^^ maxDecimalPlaces)
        guard quotientAndRemainder.remainder != 0, remainderDivisor != 0 else {
            return Self(amount: quotientResult, currency: lhs.currencyType)
        }
        let remainderResult = quotientAndRemainder.remainder / remainderDivisor
        return Self(amount: quotientResult + remainderResult, currency: lhs.currencyType)
    }

    public static func += (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs + rhs
    }

    public static func -= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs - rhs
    }

    public static func *= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs * rhs
    }

    public static func /= (lhs: inout Self, rhs: Self) throws {
        lhs = try lhs / rhs
    }

    /// Rounds the current amount to the currency's `maxDisplayableDecimalPlaces` using the provided rounding mode.
    ///
    /// - Warning:
    /// Rounding a MoneyValue means it **loses** precision of the underlying amount.
    /// This method should only be used for displaying purposes.
    ///
    /// - Parameter roundingMode: The mode used for rounding (e.g. `.up` or `.down`)
    /// - Returns: The rounded value
    public func displayableRounding(roundingMode: Decimal.RoundingMode) -> Self {
        displayableRounding(
            decimalPlaces: currency.maxDisplayableDecimalPlaces,
            roundingMode: roundingMode
        )
    }

    /// Rounds the current amount to the given precision (decimalPlaces) using the provided rounding mode.
    ///
    /// - Warning:
    /// Rounding a `MoneyValue` means it **loses** precision of the underlying amount.
    /// This method should only be used for displaying purposes.
    ///
    /// - Parameters:
    ///   - decimalPlaces: The number of decimal places to render.
    ///   - roundingMode: The mode used for rounding (e.g. `.up` or `.down`)
    /// - Returns: The rounded value
    public func displayableRounding(decimalPlaces: Int, roundingMode: Decimal.RoundingMode) -> Self {
        Self.create(
            major: amount.toDecimalMajor(
                baseDecimalPlaces: currency.maxDecimalPlaces,
                roundingDecimalPlaces: decimalPlaces,
                roundingMode: roundingMode
            ),
            currency: currencyType
        )
    }

    private static func ensureComparable(value: Self, other: Self) throws {
        if value.currency != other.currency {
            throw MoneyValueComparisonError(currencyType1: value.currency, currencyType2: other.currency)
        }
    }
}
