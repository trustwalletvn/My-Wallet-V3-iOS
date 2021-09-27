// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumAssetAccount: AssetAccount, Equatable {
    public var walletIndex: Int
    public let accountAddress: String
    public var name: String

    public init(
        walletIndex: Int,
        accountAddress: String,
        name: String
    ) {
        self.walletIndex = walletIndex
        self.accountAddress = accountAddress
        self.name = name
    }
}
