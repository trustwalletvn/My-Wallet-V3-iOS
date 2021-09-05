// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public protocol Fiat: Money {

    /// The `FiatCurrency` (e.g. `USD`, `GBP`)
    var currencyType: FiatCurrency { get }

    /// The current fiat currency value represented as a `FiatValue`
    var value: FiatValue { get }
}

extension Fiat {

    public static func zero(currencyCode: String) -> FiatValue? {
        guard let currency = FiatCurrency(code: currencyCode) else {
            return nil
        }
        return FiatValue.zero(currency: currency)
    }

    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        toDisplayString(includeSymbol: includeSymbol, format: .fullLength, locale: locale)
    }

    public func toDisplayString(
        includeSymbol: Bool,
        format: NumberFormatter.CurrencyFormat,
        locale: Locale
    ) -> String {
        /// Determine how many fraction digits should be formatted from a `FiatValue`.
        /// If the rhs of the decimal point is different than zero -> display two digits,
        /// otherwise, display without the fractional part
        let maxFractionDigits: Int
        switch format {
        case .fullLength:
            maxFractionDigits = currency.maxDecimalPlaces
        case .shortened where abs(displayMajorValue - displayMajorValue.roundTo(places: 0)) > 0:
            maxFractionDigits = currency.maxDecimalPlaces
        case .shortened:
            maxFractionDigits = 0
        }

        let formatter = FiatFormatterProvider.shared.formatter(
            locale: locale,
            fiatValue: value,
            maxFractionDigits: maxFractionDigits
        )
        return formatter.format(amount: displayMajorValue, includeSymbol: includeSymbol)
    }
}
