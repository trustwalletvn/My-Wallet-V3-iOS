// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An ERC-20 tokens endpoint response, representing a list of ERC-20 token accounts.
struct ERC20TokenAccountsResponse: Codable {

    /// The list of ERC-20 token accounts associated with the given ethereum account address.
    let tokenAccounts: [ERC20TokenAccountResponse]
}
