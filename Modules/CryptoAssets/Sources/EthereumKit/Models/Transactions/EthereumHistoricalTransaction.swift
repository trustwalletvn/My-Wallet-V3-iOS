// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import PlatformKit

public enum EthereumTransactionState: String, CaseIterable, Codable {
    case confirmed = "CONFIRMED"
    case pending = "PENDING"
    case replaced = "REPLACED"
}

public struct EthereumHistoricalTransaction {
    public static let requiredConfirmations: Int = 12

    public var fromAddress: EthereumAddress
    public var toAddress: EthereumAddress
    public var identifier: String
    public var direction: Direction
    public var amount: CryptoValue
    public var transactionHash: String
    public var createdAt: Date
    public var fee: CryptoValue?
    public var memo: String?
    public var confirmations: Int
    public var state: EthereumTransactionState
    public let data: String?

    public init(
        identifier: String,
        fromAddress: EthereumAddress,
        toAddress: EthereumAddress,
        direction: Direction,
        amount: CryptoValue,
        transactionHash: String,
        createdAt: Date,
        fee: CryptoValue?,
        memo: String?,
        confirmations: Int,
        data: String?,
        state: EthereumTransactionState
    ) {
        self.identifier = identifier
        self.fromAddress = fromAddress
        self.toAddress = toAddress
        self.direction = direction
        self.amount = amount
        self.transactionHash = transactionHash
        self.createdAt = createdAt
        self.fee = fee
        self.memo = memo
        self.confirmations = confirmations
        self.state = state
        self.data = data
    }

    public init(
        response: EthereumHistoricalTransactionResponse,
        memo: String? = nil,
        accountAddress: String,
        latestBlock: Int
    ) {
        identifier = response.hash
        fromAddress = EthereumAddress(address: response.from)!
        toAddress = EthereumAddress(address: response.to)!
        direction = EthereumHistoricalTransaction.direction(
            to: response.to,
            from: response.from,
            accountAddress: accountAddress
        )
        amount = CryptoValue(amount: BigInt(response.value) ?? 0, currency: .coin(.ethereum))
        transactionHash = response.hash
        createdAt = response.createdAt
        fee = EthereumHistoricalTransaction.fee(
            gasPrice: response.gasPrice,
            gasUsed: response.gasUsed
        )
        self.memo = memo
        confirmations = EthereumHistoricalTransaction.confirmations(
            latestBlock: latestBlock,
            blockNumber: response.blockNumber
        )
        state = response.state
        data = response.data
    }

    private static func created(timestamp: Int) -> Date {
        Date(timeIntervalSince1970: TimeInterval(timestamp))
    }

    private static func direction(to: String, from: String, accountAddress: String) -> Direction {
        let incoming = to.lowercased() == accountAddress.lowercased()
        let outgoing = from.lowercased() == accountAddress.lowercased()
        if incoming, outgoing {
            return .transfer
        }
        if incoming {
            return .debit
        }
        return .credit
    }

    private static func fee(gasPrice: String, gasUsed: String?) -> CryptoValue {
        guard let gasUsed = gasUsed else {
            return CryptoValue.zero(currency: CryptoCurrency.coin(.ethereum))
        }
        let fee = BigInt(stringLiteral: gasPrice) * BigInt(stringLiteral: gasUsed)
        return CryptoValue.create(minor: fee, currency: CryptoCurrency.coin(.ethereum))
    }

    private static func confirmations(latestBlock: Int, blockNumber: String?) -> Int {
        guard let blockNumber: Int = blockNumber.flatMap({ Int($0) }) else {
            return 0
        }
        let confirmations = (latestBlock - blockNumber) + 1
        return max(0, confirmations)
    }
}

extension EthereumHistoricalTransaction: Comparable {
    public static func < (lhs: EthereumHistoricalTransaction, rhs: EthereumHistoricalTransaction) -> Bool {
        lhs.createdAt < rhs.createdAt
    }
}

extension EthereumHistoricalTransaction: Equatable {
    public static func == (lhs: EthereumHistoricalTransaction, rhs: EthereumHistoricalTransaction) -> Bool {
        lhs.identifier == rhs.identifier
    }
}
