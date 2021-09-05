// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct FundData: Equatable {
    /// The lesser between available amount and maximum limit.
    public let topLimit: FiatValue

    init(balance: CustodialAccountBalance, max: FiatValue) {
        let fiatBalance = balance.available.fiatValue!
        let useTotalBalance = (try? fiatBalance < max) ?? false
        if useTotalBalance {
            topLimit = fiatBalance
        } else {
            topLimit = max
        }
    }
}
