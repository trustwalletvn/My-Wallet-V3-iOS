// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit

extension ERC20AssetModel {
    static func mock(name: String, precision: Int = 18, sortIndex: Int = 0) -> ERC20AssetModel {
        ERC20AssetModel(
            assetResponse: .init(
                symbol: name,
                name: name,
                precision: precision,
                products: [],
                type: .init(
                    name: "ERC20",
                    minimumOnChainConfirmations: nil,
                    parentChain: "ETH",
                    erc20Address: "ETH",
                    logoPngUrl: "ETH",
                    spotColor: nil,
                    websiteUrl: "ETH"
                )
            ),
            sortIndex: sortIndex
        )!
    }
}

extension CoinAssetModel {
    static func mock(name: String, precision: Int = 18, sortIndex: Int = 0) -> CoinAssetModel {
        CoinAssetModel(
            assetResponse: .init(
                symbol: name,
                name: name,
                precision: precision,
                products: [],
                type: .init(
                    name: "COIN",
                    minimumOnChainConfirmations: 3,
                    parentChain: nil,
                    erc20Address: nil,
                    logoPngUrl: nil,
                    spotColor: nil,
                    websiteUrl: nil
                )
            ),
            sortIndex: sortIndex
        )!
    }
}
