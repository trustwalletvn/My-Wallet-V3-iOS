// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A `NetworkCredentialProvider` allows access to credential values stored outside this module.
protocol NetworkCredentialProviderAPI {
    var apiURL: String { get }
    var exchangeURL: String { get }
    var explorerServer: String { get }
    var retailCoreURL: String { get }
    var walletServer: String { get }
    var certificatePinning: String { get }
    var everyPayURL: String { get }
    var swiftyBeaverAppId: String { get }
    var swiftyBeaverAppSecret: String { get }
    var swiftyBeaverAppKey: String { get }
}

/// This implementation of a `NetworkCredentialProviderAPI`will fetch the
/// credential values from the main Bundle info dictionary.
class NetworkCredentialProvider: NetworkCredentialProviderAPI {

    enum InfoDictionaryHelper {
        enum Key: String {
            case apiURL = "API_URL"
            case exchangeURL = "EXCHANGE_URL"
            case explorerServer = "EXPLORER_SERVER"
            case retailCoreURL = "RETAIL_CORE_URL"
            case walletServer = "WALLET_SERVER"
            case certificatePinning = "PIN_CERTIFICATE"
            case everyPayURL = "EVERYPAY_API_URL"
            case swiftyBeaverAppId = "SWIFTY_BEAVER_APP_ID"
            case swiftyBeaverAppSecret = "SWIFTY_BEAVER_APP_SECRET"
            case swiftyBeaverAppKey = "SWIFTY_BEAVER_APP_KEY"
        }

        private static let infoDictionary = Bundle.main.infoDictionary

        static func value(for key: Key) -> String! {
            infoDictionary?[key.rawValue] as? String
        }
    }

    var apiURL: String {
        InfoDictionaryHelper.value(for: .apiURL)
    }

    var exchangeURL: String {
        InfoDictionaryHelper.value(for: .exchangeURL)
    }

    var explorerServer: String {
        InfoDictionaryHelper.value(for: .explorerServer)
    }

    var retailCoreURL: String {
        InfoDictionaryHelper.value(for: .retailCoreURL)
    }

    var walletServer: String {
        InfoDictionaryHelper.value(for: .walletServer)
    }

    var certificatePinning: String {
        InfoDictionaryHelper.value(for: .certificatePinning)
    }

    var everyPayURL: String {
        InfoDictionaryHelper.value(for: .everyPayURL)
    }

    var swiftyBeaverAppId: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppId)
    }

    var swiftyBeaverAppSecret: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppSecret)
    }

    var swiftyBeaverAppKey: String {
        InfoDictionaryHelper.value(for: .swiftyBeaverAppKey)
    }
}
