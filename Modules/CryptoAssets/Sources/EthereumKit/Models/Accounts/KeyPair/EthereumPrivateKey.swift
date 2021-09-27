// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import WalletCore

public struct EthereumPrivateKey: Equatable {
    public let mnemonic: String
    public let data: Data

    init(mnemonic: String, data: Data) {
        self.mnemonic = mnemonic
        self.data = data
    }

    public var base58EncodedString: String? {
        Base58.encode(data: data)
    }
}
