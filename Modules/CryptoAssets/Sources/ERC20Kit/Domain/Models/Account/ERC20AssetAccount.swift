// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct ERC20AssetAccount: Equatable {
    public let accountAddress: String
    public let name: String

    init(accountAddress: String, name: String) {
        self.accountAddress = accountAddress
        self.name = name
    }
}
