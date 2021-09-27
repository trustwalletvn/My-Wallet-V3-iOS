// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension CryptoCurrency {
    var contractAddress: String? {
        switch self {
        case .erc20(let model):
            return model.erc20Address
        default:
            return nil
        }
    }
}
