// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ToolKit

public struct CryptoValue: CryptoMoney, Hashable {

    /// The amount in the smallest unit of the currency (i.e. satoshi for BTC, wei for ETH, etc.)
    /// a.k.a. the minor value of the currency
    public let amount: BigInt

    /// The crypto currency
    public let currencyType: CryptoCurrency

    public var value: CryptoValue {
        self
    }

    public init(amount: BigInt, currency: CryptoCurrency) {
        self.amount = amount
        currencyType = currency
    }
}

extension CryptoValue: MoneyOperating {}

extension CryptoValue {

    public func convertToFiatValue(exchangeRate: FiatValue) -> FiatValue {
        let conversionAmount = displayMajorValue * exchangeRate.displayMajorValue
        return FiatValue.create(major: conversionAmount, currency: exchangeRate.currencyType)
    }
}
