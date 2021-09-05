// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol KeyDerivationInput {

    /// The mnemonic phrase used to derive the key pair
    var mnemonic: String { get }
}
