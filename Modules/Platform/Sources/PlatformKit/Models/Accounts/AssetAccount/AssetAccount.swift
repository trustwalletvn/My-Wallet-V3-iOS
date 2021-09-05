// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol AssetAccount {
    // `accountAddress` can be an xpub,
    // eth address, public key, etc.
    var accountAddress: String { get }
    var name: String { get }
    var walletIndex: Int { get }
}
