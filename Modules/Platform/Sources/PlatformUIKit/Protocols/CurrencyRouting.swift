// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public protocol CurrencyRouting: AnyObject {
    func toSend(_ currency: CurrencyType)
    func toReceive(_ currency: CurrencyType)
}
