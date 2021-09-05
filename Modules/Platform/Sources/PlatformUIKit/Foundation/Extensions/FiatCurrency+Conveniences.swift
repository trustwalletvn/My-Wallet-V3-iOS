// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension FiatCurrency {

    public var logoResource: ImageResource {
        switch self {
        case .GBP:
            return .local(name: "icon-gbp", bundle: .platformUIKit)
        case .EUR:
            return .local(name: "icon-eur", bundle: .platformUIKit)
        case .USD:
            return .local(name: "icon-usd", bundle: .platformUIKit)
        default:
            fatalError("Currency \(code) does not have a logo image")
        }
    }

    public var brandColor: UIColor { .fiat }
}
