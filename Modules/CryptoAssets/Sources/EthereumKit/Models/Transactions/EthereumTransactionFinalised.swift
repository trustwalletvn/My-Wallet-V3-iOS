// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct EthereumTransactionFinalised: Equatable {

    public let transactionHash: String
    public let rawTransaction: String

    init(transaction: EthereumTransactionCandidateSigned) {
        self.init(
            transactionHash: transaction.transactionHash,
            rawTransaction: transaction.encodedTransaction.hexValue.withHex.lowercased()
        )
    }

    init(transactionHash: String, rawTransaction: String) {
        self.transactionHash = transactionHash
        self.rawTransaction = rawTransaction
    }
}
