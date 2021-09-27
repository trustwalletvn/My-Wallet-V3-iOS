// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct EthereumKeyPair: KeyPair, Equatable {
    public var accountID: String
    public var privateKey: EthereumPrivateKey

    public init(accountID: String, privateKey: EthereumPrivateKey) {
        self.accountID = accountID
        self.privateKey = privateKey
    }
}
