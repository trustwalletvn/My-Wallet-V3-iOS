// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct StellarPrivateKey {
    public var secret: String

    public init(secret: String) {
        self.secret = secret
    }
}
