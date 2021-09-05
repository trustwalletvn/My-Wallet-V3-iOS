// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public typealias JSON = [String: Any]

public struct WalletOptions: Decodable {

    /// App update type
    public enum UpdateType {

        /// Possible update value representation
        public enum RawValue {
            static let recommended = "recommended"
            static let forced = "forced"
            static let none = "none"
        }

        /// Recommended update with latest version availabled in store associated
        case recommended(latestVersion: AppVersion)

        /// Forced update with latest version availabled in store associated
        case forced(latestVersion: AppVersion)

        /// Update feature deactivated
        case none

        /// Raw value representing the update type
        var rawValue: String {
            switch self {
            case .recommended:
                return RawValue.recommended
            case .forced:
                return RawValue.forced
            case .none:
                return RawValue.none
            }
        }
    }

    enum Keys {
        static let domains = "domains"

        static let partners = "partners"
        static let partnerId = "partnerId"
        static let ethereum = "ethereum"
        static let lastTxFuse = "lastTxFuse"
        static let countries = "countries"
        static let mobile = "mobile"
        static let walletRoot = "walletRoot"
        static let maintenance = "maintenance"
        static let mobileInfo = "mobileInfo"
        static let shapeshift = "shapeshift"
        static let xlm = "xlm"

        static let ios = "ios"
        static let update = "update"
        static let updateType = "updateType"
        static let latestStoreVersion = "latestStoreVersion"
    }

    enum CodingKeys: String, CodingKey {
        case domains
        case partners
        case partnerId
        case countries
        case mobile
        case walletRoot
        case maintenance
        case ethereum
        case mobileInfo
        case shapeshift
        case xlm
        case ios
        case update
        case updateType
        case latestStoreVersion
        case xlmExchange
        case exchangeAddresses
    }

    public struct Domains: Decodable {

        enum CodingKeys: String, CodingKey {
            case stellarHorizon
        }

        enum Keys: String {
            case stellarHorizon
        }

        public let stellarHorizon: String?

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            stellarHorizon = try values.decodeIfPresent(String.self, forKey: .stellarHorizon)
        }
    }

    public struct Mobile: Decodable {

        public let walletRoot: String?

        enum CodingKeys: String, CodingKey {
            case walletRoot
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            walletRoot = try values.decodeIfPresent(String.self, forKey: .walletRoot)
        }
    }

    public struct MobileInfo {
        public let message: String?

        public init?(value: String?) {
            guard let input = value else { return nil }
            message = input
        }
    }

    public struct Ethereum: Decodable {
        public let lastTxFuse: Int64
    }

    public struct XLMMetadata: Decodable {
        public let operationFee: Int
        public let sendTimeOutSeconds: Int

        enum CodingKeys: String, CodingKey {
            case operationFee
            case sendTimeOutSeconds
        }

        public init(from decoder: Decoder) throws {
            let values = try decoder.container(keyedBy: CodingKeys.self)
            operationFee = try values.decode(Int.self, forKey: .operationFee)
            sendTimeOutSeconds = try values.decode(Int.self, forKey: .sendTimeOutSeconds)
        }
    }

    public struct AppUpdateMetadata: Decodable {
        let updateType: UpdateType

        enum CodingKeys: String, CodingKey {
            case update
            case updateType
            case latestStoreVersion
        }

        public init(from decoder: Decoder) throws {
            let iOSMetaData = try decoder.container(keyedBy: CodingKeys.self)
            guard iOSMetaData.contains(.update) else { updateType = .none; return }

            let updateMetaData = try iOSMetaData.nestedContainer(keyedBy: CodingKeys.self, forKey: .update)
            let updateTypeRawValue = try updateMetaData.decodeIfPresent(String.self, forKey: .updateType)
            let version = try updateMetaData.decodeIfPresent(String.self, forKey: .latestStoreVersion)
            guard let type = updateTypeRawValue, let latest = version else {
                updateType = .none
                return
            }
            guard let latestVersion = AppVersion(string: latest) else {
                updateType = .none
                return
            }
            switch type {
            case UpdateType.RawValue.forced:
                updateType = .forced(latestVersion: latestVersion)
            case UpdateType.RawValue.recommended:
                updateType = .recommended(latestVersion: latestVersion)
            default:
                updateType = .none
            }
        }
    }

    // MARK: - Properties

    public let domains: Domains?

    public let updateType: UpdateType

    public let downForMaintenance: Bool

    public let mobileInfo: MobileInfo?

    public let mobile: Mobile?

    public let xlmMetadata: XLMMetadata?

    public let ethereum: Ethereum

    public let xlmExchangeAddresses: [String]?
}

extension WalletOptions.Domains {
    public init?(json: JSON) {
        guard
            let mobile = json[WalletOptions.Keys.domains] as? [String: String],
            let stellarHorizonURLString = mobile[Keys.stellarHorizon.rawValue],
            !stellarHorizonURLString.isEmpty,
            let stellarHorizonURL = URL(string: stellarHorizonURLString)
        else {
            return nil
        }
        stellarHorizon = stellarHorizonURL.absoluteString
    }
}

extension WalletOptions.XLMMetadata {
    public init?(json: JSON) {
        if let xlmData = json[WalletOptions.Keys.xlm] as? [String: Int] {
            guard let fee = xlmData["operationFee"] else { return nil }
            guard let timeout = xlmData["sendTimeOutSeconds"] else { return nil }
            operationFee = fee
            sendTimeOutSeconds = timeout
        } else {
            return nil
        }
    }
}

extension WalletOptions.Mobile {
    public init(json: JSON) {
        if let mobile = json[WalletOptions.Keys.mobile] as? [String: String] {
            walletRoot = mobile[WalletOptions.Keys.walletRoot]
        } else {
            walletRoot = nil
        }
    }
}

extension WalletOptions.MobileInfo {
    public init(json: JSON) {
        if let mobileInfo = json[WalletOptions.Keys.mobileInfo] as? [String: String] {
            if let code = Locale.current.languageCode {
                message = mobileInfo[code] ?? mobileInfo["en"]
            } else {
                message = mobileInfo["en"]
            }
        } else {
            message = nil
        }
    }
}

extension WalletOptions.UpdateType {
    public init(json: JSON) {

        // Extract version update values
        guard let iosJson = json[WalletOptions.Keys.ios] as? JSON,
              let updateJson = iosJson[WalletOptions.Keys.update] as? JSON
        else {
            self = .none
            return
        }

        // First, verify the update type can be extracted, and fallback to `.none` if not
        guard let updateTypeRawValue = updateJson[WalletOptions.Keys.updateType] as? String else {
            self = .none
            return
        }

        // Verify the latest available version in sotre can be extracted, and fallback to `.none` if not
        guard let version = updateJson[WalletOptions.Keys.latestStoreVersion] as? String,
              let latestVersion = AppVersion(string: version)
        else {
            self = .none
            return
        }

        switch updateTypeRawValue {
        case RawValue.forced:
            self = .forced(latestVersion: latestVersion)
        case RawValue.recommended:
            self = .recommended(latestVersion: latestVersion)
        default:
            self = .none
        }
    }
}

extension WalletOptions.Ethereum {
    public init(json: JSON) {
        let ethereum = json[WalletOptions.Keys.ethereum] as? [String: Any]
        lastTxFuse = ethereum?[WalletOptions.Keys.lastTxFuse] as? Int64 ?? 0
    }
}

extension WalletOptions {
    public init(json: JSON) {
        domains = WalletOptions.Domains(json: json)
        downForMaintenance = json[Keys.maintenance] as? Bool ?? false
        mobile = WalletOptions.Mobile(json: json)
        mobileInfo = WalletOptions.MobileInfo(json: json)
        xlmMetadata = WalletOptions.XLMMetadata(json: json)
        updateType = WalletOptions.UpdateType(json: json)
        let xlmExchangeContainer = json[CodingKeys.xlmExchange.rawValue] as? [String: [String]]
        xlmExchangeAddresses = xlmExchangeContainer?[CodingKeys.exchangeAddresses.rawValue] ?? nil
        ethereum = WalletOptions.Ethereum(json: json)
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        domains = try values.decodeIfPresent(Domains.self, forKey: .domains)
        downForMaintenance = try values.decodeIfPresent(Bool.self, forKey: .maintenance) ?? false
        mobile = try values.decodeIfPresent(Mobile.self, forKey: .mobile)
        xlmMetadata = try values.decodeIfPresent(XLMMetadata.self, forKey: .xlm)
        if let mobileInfoPayload = try values.decodeIfPresent([String: String].self, forKey: .mobileInfo) {
            if let code = Locale.current.languageCode {
                mobileInfo = MobileInfo(value: mobileInfoPayload[code] ?? mobileInfoPayload["en"])
            } else {
                mobileInfo = MobileInfo(value: mobileInfoPayload["en"])
            }
        } else {
            mobileInfo = nil
        }
        let xlmExchangeAddressContainer = try values.nestedContainer(keyedBy: CodingKeys.self, forKey: .xlmExchange)
        xlmExchangeAddresses = try xlmExchangeAddressContainer.decodeIfPresent([String].self, forKey: .exchangeAddresses)
        let appUpdateMetaData = try values.decodeIfPresent(AppUpdateMetadata.self, forKey: .ios)
        if let value = appUpdateMetaData {
            updateType = value.updateType
        } else {
            updateType = .none
        }
        ethereum = try values.decode(Ethereum.self, forKey: .ethereum)
    }
}
