// Copyright © Blockchain Luxembourg S.A. All rights reserved.

protocol CoinSortingStrategy {
    func sort(coins: [UnspentOutput]) -> [UnspentOutput]
}

/// Prioritizes smaller coins, better coin consolidation but a higher fee.
struct AscentDrawSortingStrategy: CoinSortingStrategy {
    func sort(coins: [UnspentOutput]) -> [UnspentOutput] {
        coins.sorted(by: { lhs, rhs -> Bool in
            lhs.magnitude < rhs.magnitude
        })
    }
}

/// Prioritizes larger coins, worse coin consolidation but a lower fee.
struct DescentDrawSortingStrategy: CoinSortingStrategy {
    func sort(coins: [UnspentOutput]) -> [UnspentOutput] {
        coins.sorted(by: { lhs, rhs -> Bool in
            lhs.magnitude > rhs.magnitude
        })
    }
}
