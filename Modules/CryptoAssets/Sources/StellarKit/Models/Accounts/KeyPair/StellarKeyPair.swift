// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct StellarKeyPair: KeyPair {
    public var secret: String {
        privateKey.secret
    }

    public var accountID: String
    public var privateKey: StellarPrivateKey

    public init(accountID: String, secret: String) {
        self.accountID = accountID
        privateKey = StellarPrivateKey(secret: secret)
    }
}
