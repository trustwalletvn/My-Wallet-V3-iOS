// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import ToolKit

/// This is used to distinguish between different types of digital assets.
public enum CryptoCurrency: Currency, Hashable, Codable, Comparable, CustomDebugStringConvertible {

    case coin(CoinAssetModel)
    case erc20(ERC20AssetModel)

    public init?(code: String, enabledCurrenciesService: EnabledCurrenciesServiceAPI = resolve()) {
        guard let cryptoCurrency = enabledCurrenciesService.allEnabledCryptoCurrencies
            .first(where: { $0.code == code })
        else {
            return nil
        }
        self = cryptoCurrency
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        guard let cryptoCurrency = CryptoCurrency(code: stringValue) else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported currency \(stringValue)")
        }
        self = cryptoCurrency
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(code)
    }

    public var debugDescription: String {
        "CryptoCurrency.\(code)"
    }

    public var assetModel: AssetModel {
        switch self {
        case .coin(let model):
            return model
        case .erc20(let model):
            return model
        }
    }
}

// MARK: - Currency

extension CryptoCurrency {

    public static let maxDisplayableDecimalPlaces: Int = 8

    /// Sort currencies, first non ERC20 coins following `integerValue` value, then ERC20 coins sorted as we received them.
    public static func < (lhs: CryptoCurrency, rhs: CryptoCurrency) -> Bool {
        lhs.integerValue < rhs.integerValue
    }

    /// Helper value for `Comparable` conformance.
    private var integerValue: Int {
        switch self {
        case .coin(let model):
            return model.sortIndex
        case .erc20(let model):
            return 10000 + model.sortIndex
        }
    }

    public var name: String {
        switch self {
        case .erc20(let model):
            return model.name
        case .coin(let model):
            return model.name
        }
    }

    public var symbol: String { code }

    public var code: String {
        switch self {
        case .erc20(let model):
            return model.code
        case .coin(let model):
            return model.code
        }
    }

    public var displayCode: String {
        switch self {
        case .coin(let model):
            return model.code
        case .erc20(let model):
            return model.code
        }
    }

    public var maxDecimalPlaces: Int {
        switch self {
        case .erc20(let model):
            return model.precision
        case .coin(let model):
            return model.precision
        }
    }

    public var maxDisplayableDecimalPlaces: Int {
        min(8, maxDecimalPlaces)
    }

    /// Returns `true` for any ERC20 asset
    public var isERC20: Bool {
        switch self {
        case .erc20:
            return true
        case .coin:
            return false
        }
    }

    /// Returns `true` for any ERC20 asset
    public var isCoin: Bool {
        switch self {
        case .coin:
            return true
        case .erc20:
            return false
        }
    }

    /// A `Hashable` tag that can be used to discern between different L1/L2 chains.
    public var typeTag: AnyHashable {
        switch self {
        case .erc20(let model):
            return model.typeTag
        case .coin(let model):
            return model.typeTag
        }
    }
}
