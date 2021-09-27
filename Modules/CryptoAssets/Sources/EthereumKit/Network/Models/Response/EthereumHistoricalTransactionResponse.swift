// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import Foundation

struct EthereumAccountTransactionsResponse: Codable {
    let transactions: [EthereumHistoricalTransactionResponse]
    let page: String
    let size: Int
}

public struct EthereumHistoricalTransactionResponse: Codable {

    public var createdAt: Date {
        guard let timeInterval = timestamp.flatMap({ TimeInterval($0) }) else {
            return Date()
        }
        return Date(timeIntervalSince1970: timeInterval)
    }

    public let blockNumber: String?
    public let from: String
    public let gasPrice: String
    public let gasUsed: String?
    public let hash: String
    public let state: EthereumTransactionState
    public let to: String
    public let value: String
    public let data: String?
    private let timestamp: String?
}
