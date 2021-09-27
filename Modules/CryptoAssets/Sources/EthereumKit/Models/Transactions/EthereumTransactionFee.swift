// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import DIKit
import NetworkKit
import PlatformKit
import RxSwift

public struct EthereumTransactionFee {

    public enum FeeLevel {
        case regular
        case priority
    }

    static let `default` = EthereumTransactionFee(
        limits: EthereumTransactionFee.defaultLimits,
        regular: 5,
        priority: 11,
        gasLimit: 21000,
        gasLimitContract: 65000
    )
    static let defaultLimits = TransactionFeeLimits(min: 1, max: 1000)

    let limits: TransactionFeeLimits
    let regular: CryptoValue
    let priority: CryptoValue
    let gasLimit: Int
    public let gasLimitContract: Int

    init(limits: TransactionFeeLimits, regular: Int, priority: Int, gasLimit: Int, gasLimitContract: Int) {
        self.limits = limits
        self.regular = CryptoValue.ether(gwei: BigInt(regular))
        self.priority = CryptoValue.ether(gwei: BigInt(priority))
        self.gasLimit = gasLimit
        self.gasLimitContract = gasLimitContract
    }

    public func fee(feeLevel: FeeLevel) -> CryptoValue {
        switch feeLevel {
        case .regular:
            return regular
        case .priority:
            return priority
        }
    }

    public func absoluteFee(with feeLevel: FeeLevel, isContract: Bool) -> CryptoValue {
        let gasLimit = BigUInt(isContract ? gasLimitContract : self.gasLimit)
        let price = BigUInt(fee(feeLevel: feeLevel).amount)
        let amount = price * gasLimit
        guard let absoluteFee = CryptoValue.create(minor: "\(amount)", currency: .coin(.ethereum)) else {
            fatalError("Error calculating fee. price: \(price). gasLimit: \(gasLimit). amount: \(amount).")
        }
        return absoluteFee
    }
}

extension CryptoValue {

    static func ether(gwei: BigInt) -> CryptoValue {
        let wei = gwei * BigInt(1000000000)
        return CryptoValue(amount: wei, currency: .coin(.ethereum))
    }
}
