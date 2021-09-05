// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A list of supported `AssetModel`.
struct SupportedAssets {
    static let empty = SupportedAssets(currencies: [])

    let currencies: [AssetModel]

    init(response: SupportedAssetsResponse) {
        currencies = response.currencies
            .enumerated()
            .compactMap { index, asset -> AssetModel? in
                switch asset.type.name {
                // TODO: IOS-5091: remove sortIndex, cryptocurrencies should not have an order,
                // but accounts should be sorted by balance.
                case SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue:
                    return CoinAssetModel(assetResponse: asset, sortIndex: 10 + index)
                case SupportedAssetsResponse.Asset.AssetType.Name.erc20.rawValue:
                    return ERC20AssetModel(assetResponse: asset, sortIndex: 1000 + index)
                case SupportedAssetsResponse.Asset.AssetType.Name.fiat.rawValue:
                    return FiatAssetModel(assetResponse: asset)
                default:
                    #if INTERNAL_BUILD
                    fatalError("Unrecognized asset type \(asset.type.name)")
                    #else
                    return nil
                    #endif
                }
            }
    }

    private init(currencies: [AssetModel]) {
        self.currencies = currencies
    }
}
