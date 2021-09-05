// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

public struct InterestAccountRate {
    public let cryptoCurrency: CryptoCurrency
    public let rate: Double

    public init(
        currencyCode: String,
        rate: Double
    ) {
        guard let crypto = CryptoCurrency(code: currencyCode) else {
            unimplemented("This currency type is not supported")
        }
        cryptoCurrency = crypto
        self.rate = rate
    }
}
