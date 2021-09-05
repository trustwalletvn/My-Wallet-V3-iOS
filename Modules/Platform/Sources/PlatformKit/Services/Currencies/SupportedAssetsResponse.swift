// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

struct SupportedAssetsResponse: Codable {
    struct Asset: Codable {
        let symbol: String // eg BTC
        let name: String // eg Bitcoin
        let precision: Int // eg 18
        let products: [String] // eg ["PrivateKey"]
        let type: AssetType

        struct AssetType: Codable {
            enum Name: String {
                case coin = "COIN"
                case erc20 = "ERC20"
                case fiat = "FIAT"
            }

            let name: String // eg COIN, ERC20, FIAT
            let minimumOnChainConfirmations: Int? // eg 7 or nil if it is a L2 coin

            /// nil if 'COIN', or L1 parent if it is a L2 coin (ETH for ERC20)
            let parentChain: String?
            /// 0x prefixed contract address for ERC20 types, nil otherwise
            let erc20Address: String?

            let logoPngUrl: String?
            let spotColor: String?
            let websiteUrl: String?
        }
    }

    let currencies: [Asset]
}
