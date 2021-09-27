// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

extension Accessibility.Identifier {
    enum Send {}
    enum Receive {}
}

extension Accessibility.Identifier.Receive {
    private static let prefix = "Receive."
    static let walletNameLabel = "\(prefix)walletNameLabel"
    static let balanceLabel = "\(prefix)balanceLabel"
    static let addressLabel = "\(prefix)addressLabel"
    static let memoLabel = "\(prefix)memoLabel"
}
