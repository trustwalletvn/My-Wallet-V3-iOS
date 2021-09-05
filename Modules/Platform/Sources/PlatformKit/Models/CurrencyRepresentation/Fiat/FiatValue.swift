// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public struct FiatValue: Fiat, Hashable {

    /// The amount is the smallest unit of the currency (i.e. cents for USD)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt

    /// The fiat currency
    public let currencyType: FiatCurrency

    public var value: FiatValue {
        self
    }

    public init(amount: BigInt, currency: FiatCurrency) {
        self.amount = amount
        currencyType = currency
    }
}

extension FiatValue {

    // MARK: - Conversion

    /// Converts this value into a corresponding CryptoValue given an exchange rate for a given currency
    ///
    /// - Parameters:
    ///   - exchangeRate: the cost of 1 unit of cryptoCurrency provided in FiatValue
    ///   - cryptoCurrency: the currency to convert to
    /// - Returns: the converted FiatValue in CryptoValue
    public func convertToCryptoValue(exchangeRate: FiatValue, cryptoCurrency: CryptoCurrency) -> CryptoValue {
        guard !isZero else {
            return CryptoValue.zero(currency: cryptoCurrency)
        }
        guard !exchangeRate.isZero else {
            return CryptoValue.zero(currency: cryptoCurrency)
        }
        let conversionAmount = displayMajorValue / exchangeRate.displayMajorValue
        guard let result = CryptoValue.create(major: "\(conversionAmount)", currency: cryptoCurrency) else {
            // swiftlint:disable:next line_length
            fatalError("FiatValue.convertToCryptoValue conversion failed. conversionAmount: \(conversionAmount), displayMajorValue: \(displayMajorValue), exchangeRate.displayMajorValue: \(exchangeRate.displayMajorValue)")
        }
        return result
    }
}

extension FiatValue: MoneyOperating {

    /// Creates a `FiatValue` from a provided amount in major units and currency code.
    ///
    /// - Parameters:
    ///   - value: the amount as a `Decimal`
    ///   - currency: the currency
    /// - Returns: the `FiatValue`
    public static func create(major value: Decimal, currency: FiatCurrency) -> FiatValue {
        let minorDecimal = value * pow(10, currency.maxDecimalPlaces)
        return create(minor: minorDecimal, currency: currency)
    }

    private static func create(minor value: Decimal, currency: FiatCurrency) -> FiatValue {
        let amount = BigInt(stringLiteral: "\(value.roundTo(places: 0))")
        return FiatValue(amount: amount, currency: currency)
    }
}
