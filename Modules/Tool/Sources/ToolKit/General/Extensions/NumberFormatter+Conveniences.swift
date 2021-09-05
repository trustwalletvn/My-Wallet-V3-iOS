// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension NumberFormatter {

    /// The format of a currency
    public enum CurrencyFormat {

        /// In case the rhs to the decimal separator is 0, it would be trimmed: e.g `23.00` -> `23`
        case shortened

        /// Doesn't get trimmed. e.g `23.00` -> `23.00`
        case fullLength
    }

    public convenience init(locale: Locale, currencyCode: String, maxFractionDigits: Int) {
        self.init()
        usesGroupingSeparator = true
        roundingMode = .down
        numberStyle = .currency
        self.locale = locale
        self.currencyCode = currencyCode
        maximumFractionDigits = maxFractionDigits
    }

    public func format(amount: Decimal, includeSymbol: Bool) -> String {
        let formattedString = string(from: NSDecimalNumber(decimal: amount)) ?? "\(amount)"
        if let firstDigitIndex = formattedString.firstIndex(where: { $0.inSet(characterSet: .decimalDigits) }),
           let lastDigitIndex = formattedString.lastIndex(where: { $0.inSet(characterSet: .decimalDigits) }),
           !includeSymbol
        {
            return String(formattedString[firstDigitIndex...lastDigitIndex])
        }
        return formattedString
    }
}
