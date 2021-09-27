// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

struct SpendableUnspentOutputs: Equatable {

    // FIXME: Should this be a BitcoinValue?
    var spendableBalance: BigUInt {
        spendableOutputs.sum() - absoluteFee
    }

    let spendableOutputs: [UnspentOutput]

    // FIXME: Should this be a BitcoinValue?
    let absoluteFee: BigUInt

    // FIXME: Should this be a BitcoinValue?
    let consumedAmount: BigUInt

    let isReplayProtected: Bool

    init(
        spendableOutputs: [UnspentOutput] = [],
        absoluteFee: BigUInt = BigUInt.zero,
        consumedAmount: BigUInt = BigUInt.zero,
        isReplayProtected: Bool = false
    ) {
        self.spendableOutputs = spendableOutputs
        self.absoluteFee = absoluteFee
        self.consumedAmount = consumedAmount
        self.isReplayProtected = isReplayProtected
    }
}
