// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct SavingsAccountBalanceDetails: Decodable {

    public let balance: String?
    public let pendingInterest: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?

    private enum CodingKeys: String, CodingKey {
        case balance
        case pendingInterest
        case totalInterest
        case pendingWithdrawal
        case pendingDeposit
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        balance = try values.decodeIfPresent(String.self, forKey: .balance)
        pendingDeposit = try values.decodeIfPresent(String.self, forKey: .pendingDeposit)
        pendingInterest = try values.decodeIfPresent(String.self, forKey: .pendingInterest)
        pendingWithdrawal = try values.decodeIfPresent(String.self, forKey: .pendingWithdrawal)
        totalInterest = try values.decodeIfPresent(String.self, forKey: .totalInterest)
    }
}
