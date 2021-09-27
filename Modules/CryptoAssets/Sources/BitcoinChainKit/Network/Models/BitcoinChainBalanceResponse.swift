// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public typealias BitcoinChainBalanceResponse = [String: BitcoinChainBalanceItemResponse]

public struct BitcoinChainBalanceItemResponse: Decodable {

    private enum CodingKeys: String, CodingKey {
        case finalBalance = "final_balance"
        case nTx = "n_tx"
        case totalReceived = "total_received"
    }

    public let finalBalance: Int

    public let nTx: Int

    public let totalReceived: Int
}
