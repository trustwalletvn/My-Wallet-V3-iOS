// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public protocol Money: CustomDebugStringConvertible {

    /// The type of currency (e.g. `fiat` or `crypto`)
    var currency: CurrencyType { get }

    /// The amount is the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    var amount: BigInt { get }

    /// The fiat or crypto currency code (e.g. `USD` or `BTC`), defined by `FiatCurrency` and `CryptoCurrency`
    var currencyCode: String { get }

    /// The currency symbol (e.g. `£`, `$`)
    var symbol: String { get }

    /// Returns `true` if the value is exactly `0`
    var isZero: Bool { get }

    /// Returns `true` if the value is greater than `0`
    var isPositive: Bool { get }

    /// Returns `true` if the value is less than `0`
    var isNegative: Bool { get }

    /// The maximum number of decimal places supported by the money
    var maxDecimalPlaces: Int { get }

    /// The maximum number of displayable decimal places.
    var maxDisplayableDecimalPlaces: Int { get }

    /// The minor value of the currency
    var minorString: String { get }

    /// The major value as `String` rendered using the current locale and default formatter
    var displayString: String { get }

    /// The major value as `Decimal` truncated to `maxDecimalPlaces`
    var displayMajorValue: Decimal { get }

    /// Converts this money to a displayable String
    ///
    /// - Parameter locale: the `Locale` used to render the string
    /// - Returns: the displayable String
    func toDisplayString(locale: Locale) -> String

    /// Converts this money to a displayable String
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Returns: the displayable String
    func toDisplayString(includeSymbol: Bool) -> String

    /// Converts this money to a displayable String
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Parameter locale: the `Locale` used to render the string
    /// - Returns: the displayable String
    func toDisplayString(includeSymbol: Bool, locale: Locale) -> String
}

extension Money {

    public var debugDescription: String {
        "\(type(of: self)) \(code) \(amount)"
    }

    public var code: String {
        currency.code
    }

    public var displayCode: String {
        currency.displayCode
    }

    public var maxDecimalPlaces: Int {
        currency.maxDecimalPlaces
    }

    public var maxDisplayableDecimalPlaces: Int {
        currency.maxDisplayableDecimalPlaces
    }

    public var minorString: String {
        amount.description
    }

    @available(*, deprecated, message: "please use `displayString` instead")
    public var displayMajorValue: Decimal {
        amount.toDecimalMajor(baseDecimalPlaces: currency.maxDecimalPlaces, roundingDecimalPlaces: currency.maxDecimalPlaces)
    }

    public var currencyCode: String {
        currency.code
    }

    public var symbol: String {
        currency.symbol
    }

    public var isZero: Bool {
        amount.isZero
    }

    public var isPositive: Bool {
        amount > 0
    }

    public var isNegative: Bool {
        amount < 0
    }

    public var displayString: String {
        toDisplayString(includeSymbol: true)
    }

    public func toDisplayString(locale: Locale) -> String {
        toDisplayString(includeSymbol: true, locale: locale)
    }

    public func toDisplayString(includeSymbol: Bool) -> String {
        toDisplayString(includeSymbol: includeSymbol, locale: Locale.current)
    }
}
