// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public enum Direction: String {
    /// A `credit` is an **increase** in liabilities (decrease in cash)
    /// relative to the account
    case credit

    /// A `debit` is an **increase** in cash relative to the account
    case debit

    /// `ETH` specific
    case transfer
}
