// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumAssetAccountDetails: Equatable {

    public let account: EthereumAssetAccount
    public let balance: CryptoValue
    public let nonce: UInt64

    public init(account: EthereumAssetAccount, balance: CryptoValue, nonce: UInt64) {
        self.account = account
        self.balance = balance
        self.nonce = nonce
    }
}
