// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CryptoCurrency {
    /// Indicates whether the currency supports bit pay transactions
    var supportsBitPay: Bool {
        self == .coin(.bitcoin)
    }
}
