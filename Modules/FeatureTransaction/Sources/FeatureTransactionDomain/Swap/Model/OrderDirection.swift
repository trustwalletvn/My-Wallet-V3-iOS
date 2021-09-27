// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension OrderDirection {
    var requiresDestinationAddress: Bool {
        switch self {
        case .onChain,
             .toUserKey:
            return true
        case .fromUserKey,
             .internal:
            return false
        }
    }

    var requiresRefundAddress: Bool {
        switch self {
        case .onChain,
             .fromUserKey:
            return true
        case .toUserKey,
             .internal:
            return false
        }
    }
}
