// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// An ERC-20 tokens endpoint response sub-item, representing an ERC-20 token account.
struct ERC20TokenAccountResponse: Codable {

    /// The ERC-20 contract address of the token.
    let tokenHash: String

    /// The balance of the account, in minor units.
    let balance: String

    /// The symbol of the ERC-20 token (e.g. `AAVE`, `YFI`, etc.).
    let tokenSymbol: String
}
