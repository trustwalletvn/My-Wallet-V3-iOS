// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Enumerates the different precision levels for formatting a `CryptoValue` into a String
///
/// - short: a short precision (e.g. ETH has 18 precision but displayable precision is less)
/// - long: a long precision (i.e. the full precision of the currency)
public enum CryptoPrecision {
    case short
    case long
}

public final class CryptoFormatterProvider {

    static let shared = CryptoFormatterProvider()

    private var formatterMap = [String: CryptoFormatter]()
    private let queue = DispatchQueue(label: "CryptoFormatterProvider.queue.\(UUID().uuidString)")

    public init() {}

    /// Returns `CryptoFormatter`. This method executes on a dedicated queue.
    public func formatter(locale: Locale, cryptoCurrency: CryptoCurrency, minFractionDigits: Int = 1) -> CryptoFormatter {
        var formatter: CryptoFormatter!
        queue.sync { [unowned self] in
            let mapKey = key(locale: locale, cryptoCurrency: cryptoCurrency)
            if let matchingFormatter = formatterMap[mapKey] {
                formatter = matchingFormatter
            } else {
                formatter = CryptoFormatter(
                    locale: locale,
                    cryptoCurrency: cryptoCurrency,
                    minFractionDigits: minFractionDigits
                )
                self.formatterMap[mapKey] = formatter
            }
        }
        return formatter
    }

    private func key(locale: Locale, cryptoCurrency: CryptoCurrency) -> String {
        guard let languageCode = locale.languageCode else {
            return cryptoCurrency.displayCode
        }
        return "\(languageCode)_\(cryptoCurrency.displayCode)"
    }
}

public final class CryptoFormatter {

    private let shortFormatter: NumberFormatter
    private let longFormatter: NumberFormatter
    private let cryptoCurrency: CryptoCurrency

    public init(locale: Locale, cryptoCurrency: CryptoCurrency, minFractionDigits: Int) {
        shortFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minFractionDigits: minFractionDigits,
            maxFractionDigits: cryptoCurrency.maxDisplayableDecimalPlaces
        )
        longFormatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minFractionDigits: minFractionDigits,
            maxFractionDigits: cryptoCurrency.maxDecimalPlaces
        )
        self.cryptoCurrency = cryptoCurrency
    }

    public func format(value: CryptoValue, withPrecision precision: CryptoPrecision = CryptoPrecision.short, includeSymbol: Bool = false) -> String {
        let formatter = (precision == .short) ? shortFormatter : longFormatter
        var formattedString = formatter.string(from: NSDecimalNumber(decimal: value.displayMajorValue)) ?? "\(value.displayMajorValue)"
        if includeSymbol {
            formattedString += " " + value.currencyType.displayCode
        }
        return formattedString
    }
}

extension NumberFormatter {
    static func cryptoFormatter(locale: Locale, minFractionDigits: Int, maxFractionDigits: Int) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = locale
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        formatter.minimumFractionDigits = minFractionDigits
        formatter.maximumFractionDigits = maxFractionDigits
        formatter.roundingMode = .down
        return formatter
    }
}
