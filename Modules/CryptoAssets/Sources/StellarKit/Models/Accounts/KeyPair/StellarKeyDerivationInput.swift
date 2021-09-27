// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct StellarKeyDerivationInput: KeyDerivationInput, Equatable {
    /// The mnemonic phrase used to derive the key pair
    public let mnemonic: String

    /// An optional passphrase for deriving the key pair
    public let passphrase: String?

    /// The index of the wallet
    public let index: Int

    public init(mnemonic: String, passphrase: String? = nil, index: Int = 0) {
        self.mnemonic = mnemonic
        self.passphrase = passphrase
        self.index = index
    }
}
