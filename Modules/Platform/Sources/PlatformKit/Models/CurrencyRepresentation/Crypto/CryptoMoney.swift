// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

public protocol CryptoMoney: Money {

    /// The `CryptoCurrency` (e.g. `BTC`, `ETH`)
    var currencyType: CryptoCurrency { get }

    /// The current crypto currency value represented as a `CryptoValue`
    var value: CryptoValue { get }
}

extension CryptoMoney {

    /// Converts this money to a displayable String in its major format
    ///
    /// - Parameter includeSymbol: whether or not the symbol should be included in the string
    /// - Returns: the displayable String
    public func toDisplayString(includeSymbol: Bool, locale: Locale) -> String {
        let formatter = CryptoFormatterProvider.shared.formatter(locale: locale, cryptoCurrency: currencyType)
        return formatter.format(value: value, withPrecision: .short, includeSymbol: includeSymbol)
    }
}
