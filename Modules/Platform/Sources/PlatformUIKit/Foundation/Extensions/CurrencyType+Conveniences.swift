// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CurrencyType {

    public var logoResource: ImageResource {
        switch self {
        case .crypto(let currency):
            return currency.logoResource
        case .fiat(let currency):
            return currency.logoResource
        }
    }

    public var brandColor: UIColor {
        switch self {
        case .crypto(let currency):
            return currency.brandColor
        case .fiat(let currency):
            return currency.brandColor
        }
    }
}
