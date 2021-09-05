// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit

/// This pattern is used to temporarily present new crypto-currencies in features like airdrops.
/// When the currency is fully supported, the case should be removed from `TriageCryptoCurrency`
/// and put in `CryptoCurrency` in its stead.
public enum TriageCryptoCurrency: Equatable {
    enum CryptoError: Error {
        case cryptoCurrencyAdditionRequired
    }

    case blockstack
    case supported(CryptoCurrency)

    public var code: String {
        switch self {
        case .blockstack:
            return "STX"
        case .supported(let currency):
            return currency.code
        }
    }

    public var displayCode: String {
        switch self {
        case .blockstack:
            return "STX"
        case .supported(let currency):
            return currency.displayCode
        }
    }

    public var cryptoCurrency: CryptoCurrency? {
        switch self {
        case .supported(let currency):
            return currency
        case .blockstack:
            return nil
        }
    }

    public var maxDecimalPlaces: Int {
        switch self {
        case .supported(let currency):
            return currency.maxDecimalPlaces
        case .blockstack:
            return 7
        }
    }

    public var maxDisplayableDecimalPlaces: Int {
        switch self {
        case .supported(let currency):
            return currency.maxDisplayableDecimalPlaces
        case .blockstack:
            return 7
        }
    }

    public func displayValue(amount: BigInt, locale: Locale = Locale.current) -> String {
        let divisor = BigInt(10).power(maxDecimalPlaces)
        var majorValue = amount.decimalDivision(divisor: divisor)
        majorValue = majorValue.roundTo(places: maxDecimalPlaces)

        let formatter = NumberFormatter.cryptoFormatter(
            locale: locale,
            minFractionDigits: 1,
            maxFractionDigits: maxDisplayableDecimalPlaces
        )
        return formatter.string(from: NSDecimalNumber(decimal: majorValue)) ?? "\(majorValue)"
    }
}

extension TriageCryptoCurrency {
    public init(cryptoCurrency: CryptoCurrency) {
        self = .supported(cryptoCurrency)
    }

    public init(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) throws {
        if let supportedCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies.first(where: { $0.code == code }) {
            self = .supported(supportedCurrency)
        } else {
            switch code {
            case TriageCryptoCurrency.blockstack.code:
                self = .blockstack
            default:
                throw CryptoError.cryptoCurrencyAdditionRequired
            }
        }
    }
}
