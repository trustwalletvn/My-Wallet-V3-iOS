// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public protocol MoneyImplementing: Money {

    associatedtype MoneyCurrency: Currency

    var currencyType: MoneyCurrency { get }

    var value: Self { get }

    init(amount: BigInt, currency: MoneyCurrency)
}

extension MoneyImplementing {

    public var currency: CurrencyType {
        currencyType.currency
    }

    // MARK: - Zero

    /// The `0` value of the currency (e.g. `0 USD`, or `0 BTC`)
    /// - Parameter currency: the currency
    public static func zero(currency: MoneyCurrency) -> Self {
        Self(amount: BigInt.zero, currency: currency)
    }

    /// The `1` value of the currency (e.g. `1 USD`, or `1 BTC`)
    /// - Parameter currency: the currency
    public static func one(currency: MoneyCurrency) -> Self {
        Self(
            amount: BigInt.one.toMinor(maxDecimalPlaces: currency.maxDecimalPlaces),
            currency: currency
        )
    }

    // MARK: - Major value

    /// Creates a `Money` conforming type from a provided a `String` value in major units and currency code.
    /// This method assumes that the `String` decimal representation is rendered using `Locale.current`.
    /// If the `value` is invalid this method will return `nil`
    ///
    /// - Parameters:
    ///   - value: the amount as a `String` in major units rendered using `Locale.current`
    ///   - currency: the crypto currency
    /// - Returns: the `Money` conforming type
    public static func create(majorDisplay value: String, currency: MoneyCurrency) -> Self? {
        create(major: value, currency: currency, locale: Locale.current)
    }

    /// Creates a `Money` conforming type from a provided a `String` value in major units and currency code.
    /// This method assumes that the `String` decimal representation is rendered in the `en_US_POSIX` locale.
    /// If the `value` is invalid this method will return `nil`.
    ///
    /// - Parameters:
    ///   - value: the amount as a `String` in major units rendered using `en_US_POSIX`
    ///   - currency: the crypto currency
    /// - Returns: the `Money` conforming type
    public static func create(major value: String, currency: MoneyCurrency) -> Self? {
        create(major: value, currency: currency, locale: Locale.Posix)
    }

    // MARK: - Minor value

    /// Creates a `Money` conforming type from a provided a `String` value in minor units and currency code.
    /// This method assumes that the `String` decimal representation is rendered using `Locale.current`.
    /// If the `value` is invalid this method will return `nil`.
    ///
    /// - Parameters:
    ///   - value: the amount as a `String` in minor units rendered using `Locale.current`
    ///   - currency: the crypto currency
    /// - Returns: the `Money` conforming type
    public static func create(minorDisplay value: String, currency: MoneyCurrency) -> Self? {
        guard let minorDecimal = Decimal(string: value, locale: Locale.current), !minorDecimal.isNaN else {
            return nil
        }
        return create(minor: minorDecimal, currency: currency)
    }

    /// Creates a `Money` conforming type from a provided amount in minor units and currency code.
    /// This method assumes that the `String` decimal representation is rendered in the `en_US_POSIX` locale.
    /// If the `value` is invalid this method will return `nil`.
    ///
    /// - Parameters:
    ///   - value: the amount as a `String` in minor units rendered using `en_US_POSIX`
    ///   - currency: the currency
    /// - Returns: the `Money` conforming type
    public static func create(minor value: String, currency: MoneyCurrency) -> Self? {
        guard let valueInBigInt = BigInt(value) else {
            return nil
        }
        return Self(amount: valueInBigInt, currency: currency)
    }

    /// Creates a `Money` conforming type from a provided a `BigInt` value in minor units and currency code.
    /// - Parameters:
    ///   - value: the amount in minor units
    ///   - currency: the crypto currency
    /// - Returns: the `Money` conforming type
    public static func create(minor value: BigInt, currency: MoneyCurrency) -> Self {
        Self(amount: value, currency: currency)
    }

    /// Creates a `Money` conforming type from a provided a `Int` value in minor units and currency code.
    /// - Parameters:
    ///   - value: the amount in minor units
    ///   - currency: the crypto currency
    /// - Returns: the `Money` conforming type
    public static func create(minor value: Int, currency: MoneyCurrency) -> Self {
        Self(amount: BigInt(value), currency: currency)
    }

    // MARK: - Private methods

    private static func create(major value: String, currency: MoneyCurrency, locale: Locale) -> Self? {
        guard let majorDecimal = Decimal(string: value, locale: locale), !majorDecimal.isNaN else {
            return nil
        }
        return create(major: majorDecimal, currency: currency)
    }

    public static func create(major value: Decimal, currency: MoneyCurrency) -> Self {
        let minorDecimal = value * pow(10, currency.maxDecimalPlaces)
        return create(minor: minorDecimal, currency: currency)
    }

    private static func create(minor value: Decimal, currency: MoneyCurrency) -> Self {
        let amount = BigInt(stringLiteral: "\(value.roundTo(places: 0))")
        return Self(amount: amount, currency: currency)
    }
}
