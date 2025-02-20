// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct InterestAccountBalances {

    public static let empty = InterestAccountBalances()

    // MARK: - Properties

    public let balances: [String: InterestAccountBalanceDetails]

    // MARK: - Init

    public init(balances: [String: InterestAccountBalanceDetails]) {
        self.balances = balances
    }

    private init() {
        balances = [:]
    }

    // MARK: - Subscript

    public subscript(currency: CryptoCurrency) -> InterestAccountBalanceDetails? {
        balances[currency.code]
    }
}
