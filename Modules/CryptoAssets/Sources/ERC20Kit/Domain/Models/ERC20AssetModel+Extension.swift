// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import EthereumKit
import PlatformKit

extension ERC20AssetModel {
    var contractAddress: EthereumAddress {
        EthereumAddress(address: erc20Address)!
    }
}
