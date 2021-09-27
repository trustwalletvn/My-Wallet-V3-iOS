// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import FeatureTransactionDomain
import PlatformKit
import RxSwift

public struct BitcoinChainTransactionFee<Token: BitcoinChainToken>: TransactionFee, Decodable {
    public static var cryptoType: HasPathComponent {
        Token.coin.cryptoCurrency
    }

    public static var `default`: BitcoinChainTransactionFee<Token> {
        switch Token.coin {
        case .bitcoin:
            return BitcoinChainTransactionFee<Token>(
                limits: BitcoinChainTransactionFee.defaultLimits, regular: 5, priority: 11
            )
        case .bitcoinCash:
            return BitcoinChainTransactionFee<Token>(
                limits: BitcoinChainTransactionFee.defaultLimits,
                regular: 5,
                priority: 11
            )
        }
    }

    public static var defaultLimits: TransactionFeeLimits {
        TransactionFeeLimits(min: 2, max: 16)
    }

    public var limits: TransactionFeeLimits
    public var regular: CryptoValue
    public var priority: CryptoValue

    enum CodingKeys: String, CodingKey {
        case regular
        case priority
        case limits
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let regularFee = try values.decode(Int.self, forKey: .regular)
        let priorityFee = try values.decode(Int.self, forKey: .priority)
        switch Token.coin {
        case .bitcoin:
            regular = CryptoValue(amount: BigInt(regularFee), currency: .coin(.bitcoin))
            priority = CryptoValue(amount: BigInt(priorityFee), currency: .coin(.bitcoin))
            limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
        case .bitcoinCash:
            regular = CryptoValue(amount: BigInt(regularFee), currency: .coin(.bitcoinCash))
            priority = CryptoValue(amount: BigInt(priorityFee), currency: .coin(.bitcoinCash))
            limits = try values.decode(TransactionFeeLimits.self, forKey: .limits)
        }
    }

    init(limits: TransactionFeeLimits, regular: Int, priority: Int) {
        self.limits = limits
        switch Token.coin {
        case .bitcoin:
            self.regular = CryptoValue(amount: BigInt(regular), currency: .coin(.bitcoin))
            self.priority = CryptoValue(amount: BigInt(priority), currency: .coin(.bitcoin))
        case .bitcoinCash:
            self.regular = CryptoValue(amount: BigInt(regular), currency: .coin(.bitcoinCash))
            self.priority = CryptoValue(amount: BigInt(priority), currency: .coin(.bitcoinCash))
        }
    }
}
