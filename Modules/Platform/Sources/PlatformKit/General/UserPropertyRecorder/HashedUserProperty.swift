// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import Foundation
import ToolKit

extension HashedUserProperty {
    public init(key: Key, value: String, truncatesValueIfNeeded: Bool = true) {
        self.init(
            key: key,
            valueHash: value.sha256,
            truncatesValueIfNeeded: truncatesValueIfNeeded
        )
    }
}
