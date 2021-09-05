// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import ToolKit

extension CryptoCurrency {

    // MARK: - UIColor

    public var brandColor: UIColor {
        switch self {
        case .coin(let model):
            if let match = CustodialCoinCode.allCases.first(where: { $0.rawValue == model.code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return model.spotColor.flatMap(UIColor.init(hex:)) ?? .black
        case .erc20(let model):
            if let match = ERC20Code.allCases.first(where: { $0.rawValue == model.code }) {
                return UIColor(hex: match.spotColor) ?? .black
            }
            return model.spotColor.flatMap(UIColor.init(hex:)) ?? UIColor(hex: "473BCB")!
        }
    }

    /// Defaults to brand color with 15% opacity.
    public var accentColor: UIColor {
        brandColor.withAlphaComponent(0.15)
    }

    // MARK: Logo Image `ImageResource`

    public var logoResource: ImageResource {
        switch self {
        case .coin(let model):
            switch model.code {
            case NonCustodialCoinCode.bitcoin.rawValue:
                return .local(name: "crypto-btc", bundle: .platformUIKit)
            case NonCustodialCoinCode.bitcoinCash.rawValue:
                return .local(name: "crypto-bch", bundle: .platformUIKit)
            case NonCustodialCoinCode.ethereum.rawValue:
                return .local(name: "crypto-eth", bundle: .platformUIKit)
            case NonCustodialCoinCode.stellar.rawValue:
                return .local(name: "crypto-xlm", bundle: .platformUIKit)
            default:
                guard let logoPngUrl = model.logoPngUrl else {
                    return .local(name: "crypto-placeholder", bundle: .platformUIKit)
                }
                return .remote(url: logoPngUrl)
            }
        case .erc20(let model):
            guard let logoPngUrl = model.logoPngUrl else {
                return .local(name: "crypto-placeholder", bundle: .platformUIKit)
            }
            return .remote(url: logoPngUrl)
        }
    }
}
