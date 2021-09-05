// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A Level 1 coin AssetModel.
public struct CoinAssetModel: AssetModel, Hashable {
    public let code: String
    public let kind: AssetModelType = .coin
    public let name: String
    public let precision: Int
    public let products: [AssetModelProduct]
    public let logoPngUrl: String?
    public let spotColor: String?
    public let minimumOnChainConfirmations: Int
    let sortIndex: Int

    public var typeTag: AnyHashable { "\(kind).\(code)" }

    init?(assetResponse: SupportedAssetsResponse.Asset, sortIndex: Int) {
        precondition(assetResponse.type.name == SupportedAssetsResponse.Asset.AssetType.Name.coin.rawValue)
        code = assetResponse.symbol
        name = assetResponse.name
        logoPngUrl = assetResponse.type.logoPngUrl
        spotColor = assetResponse.type.spotColor
        precision = assetResponse.precision
        products = assetResponse.products.compactMap(AssetModelProduct.init)
        minimumOnChainConfirmations = assetResponse.type.minimumOnChainConfirmations!
        self.sortIndex = sortIndex
    }

    init(
        code: String,
        name: String,
        precision: Int,
        products: [AssetModelProduct],
        logoPngUrl: String?,
        spotColor: String?,
        minimumOnChainConfirmations: Int,
        sortIndex: Int
    ) {
        self.code = code
        self.name = name
        self.precision = precision
        self.products = products
        self.logoPngUrl = logoPngUrl
        self.spotColor = spotColor
        self.minimumOnChainConfirmations = minimumOnChainConfirmations
        self.sortIndex = sortIndex
    }

    func with(products: [AssetModelProduct]) -> CoinAssetModel {
        CoinAssetModel(
            code: code,
            name: name,
            precision: precision,
            products: products,
            logoPngUrl: logoPngUrl,
            spotColor: spotColor,
            minimumOnChainConfirmations: minimumOnChainConfirmations,
            sortIndex: sortIndex
        )
    }
}

extension CoinAssetModel {

    public static var bitcoin: CoinAssetModel {
        CoinAssetModel(
            code: "BTC",
            name: "Bitcoin",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "FF9B22",
            minimumOnChainConfirmations: 2,
            sortIndex: 1
        )
    }

    public static var bitcoinCash: CoinAssetModel {
        CoinAssetModel(
            code: "BCH",
            name: "Bitcoin Cash",
            precision: 8,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "8DC351",
            minimumOnChainConfirmations: 3,
            sortIndex: 3
        )
    }

    public static var ethereum: CoinAssetModel {
        CoinAssetModel(
            code: "ETH",
            name: "Ethereum",
            precision: 18,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "473BCB",
            minimumOnChainConfirmations: 30,
            sortIndex: 2
        )
    }

    public static var stellar: CoinAssetModel {
        CoinAssetModel(
            code: "XLM",
            name: "Stellar",
            precision: 7,
            products: AssetModelProduct.allCases,
            logoPngUrl: nil,
            spotColor: "000000",
            minimumOnChainConfirmations: 3,
            sortIndex: 4
        )
    }
}
