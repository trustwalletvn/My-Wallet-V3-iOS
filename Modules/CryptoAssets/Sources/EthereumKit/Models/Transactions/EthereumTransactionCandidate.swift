// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

public struct EthereumTransactionCandidate: Equatable {
    enum TransferType: Equatable {
        case transfer
        case erc20Transfer(contract: EthereumAddress)
    }

    let to: EthereumAddress
    let gasPrice: BigUInt
    let gasLimit: BigUInt
    let value: BigUInt
    let data: Data?
    let transferType: TransferType

    init(
        to: EthereumAddress,
        gasPrice: BigUInt,
        gasLimit: BigUInt,
        value: BigUInt,
        data: Data?,
        transferType: TransferType
    ) {
        self.to = to
        self.gasPrice = gasPrice
        self.gasLimit = gasLimit
        self.value = value
        self.data = data
        self.transferType = transferType
    }
}
