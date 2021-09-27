// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public enum BitcoinValueError: Error {
    case invalidCryptoValue
    case invalidAmount
}

public struct BitcoinValue: CryptoMoney {

    public let currency: CurrencyType = .crypto(.coin(.bitcoin))

    public let currencyType: CryptoCurrency = .coin(.bitcoin)

    public var amount: BigInt {
        crypto.amount
    }

    public static let zero = BitcoinValue(satoshis: 0)

    public var value: CryptoValue {
        crypto.value
    }

    private let crypto: CryptoMoney

    public init(crypto: CryptoMoney) throws {
        guard crypto.currencyType == .coin(.bitcoin) else {
            throw BitcoinValueError.invalidCryptoValue
        }
        self.crypto = crypto
    }

    public init(satoshis: BigInt) {
        crypto = CryptoValue(amount: satoshis, currency: .coin(.bitcoin))
    }
}

extension BitcoinValue: Equatable {
    public static func == (lhs: BitcoinValue, rhs: BitcoinValue) -> Bool {
        lhs.amount == rhs.amount
    }
}
