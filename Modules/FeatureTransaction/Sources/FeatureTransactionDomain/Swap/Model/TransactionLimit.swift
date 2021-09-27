// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public struct TransactionLimit {
    public let limit: FiatValue
    public let available: FiatValue
    public let used: FiatValue

    public init(limit: FiatValue, available: FiatValue, used: FiatValue) {
        self.limit = limit
        self.available = available
        self.used = used
    }
}
