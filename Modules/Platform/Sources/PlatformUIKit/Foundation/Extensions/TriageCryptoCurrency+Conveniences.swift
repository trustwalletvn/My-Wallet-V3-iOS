// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension TriageCryptoCurrency {

    public var logoResource: ImageResource {
        switch self {
        case .blockstack:
            return .local(name: "crypto-stx", bundle: .platformUIKit)
        case .supported(let currency):
            return currency.logoResource
        }
    }
}
