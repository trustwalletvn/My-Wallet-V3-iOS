// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct InterestAccountBalanceDetails {
    public let balance: String?
    public let pendingInterest: String?
    public let totalInterest: String?
    public let pendingWithdrawal: String?
    public let pendingDeposit: String?

    public init(
        balance: String? = nil,
        pendingInterest: String? = nil,
        totalInterest: String? = nil,
        pendingWithdrawal: String? = nil,
        pendingDeposit: String? = nil
    ) {
        self.balance = balance
        self.pendingDeposit = pendingDeposit
        self.pendingInterest = pendingInterest
        self.totalInterest = totalInterest
        self.pendingWithdrawal = pendingWithdrawal
    }
}
