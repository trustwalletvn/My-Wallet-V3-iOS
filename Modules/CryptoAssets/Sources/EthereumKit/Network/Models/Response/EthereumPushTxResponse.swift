// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct EthereumPushTxResponse: Decodable, Equatable {
    public let txHash: String

    public init(txHash: String) {
        self.txHash = txHash
    }
}
