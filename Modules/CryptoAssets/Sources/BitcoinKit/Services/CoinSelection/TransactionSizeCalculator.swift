// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

protocol TransactionSizeCalculating {
    func transactionBytes(inputs: Int, outputs: Int) -> BigUInt
    func dustThreshold(for fee: Fee) -> BigUInt
}

struct TransactionSizeCalculator: TransactionSizeCalculating {
    func transactionBytes(inputs: Int, outputs: Int) -> BigUInt {
        CoinSelection.Constants.costBase
            + CoinSelection.Constants.costPerInput.multiplied(by: BigUInt(inputs))
            + CoinSelection.Constants.costPerOutput.multiplied(by: BigUInt(outputs))
    }

    func dustThreshold(for fee: Fee) -> BigUInt {
        (CoinSelection.Constants.costPerInput + CoinSelection.Constants.costPerOutput) * fee.feePerByte
    }
}
