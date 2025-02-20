// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol Account {

    /// A user-facing description for the account.
    var label: String { get }

    /// The `CurrencyType` of the account
    var currencyType: CurrencyType { get }
}
