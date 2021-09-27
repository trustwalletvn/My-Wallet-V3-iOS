// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Defines an internal feature as part of a FeatureFlag
public enum InternalFeature: String, CaseIterable {

    /// Enable secure channel
    case secureChannel

    /// Enabled console logging of network requests for debug builds
    case requestConsoleLogging

    /// Uses the Transactions Flow implementation of Buy when enabled
    case useTransactionsFlowToBuyCrypto

    /// Uses the Transactions Flow implementation of Sell when enabled
    case useTransactionsFlowToSellCrypto

    /// Enable interest withdraw and deposit
    case interestWithdrawAndDeposit

    /// Disable the guid login at welcome screen, useful for demo purposes
    /// - Note: Old manual guid login screen is used only for internal builds
    case disableGUIDLogin

    /// Enable split dashboard screen.
    case splitDashboard

    /// Enables the feature for alpha release overriding internal config.
    var isAlphaReady: Bool {
        switch self {
        case .interestWithdrawAndDeposit:
            return false
        case .secureChannel:
            return false
        case .requestConsoleLogging:
            return false
        case .useTransactionsFlowToBuyCrypto:
            return false
        case .useTransactionsFlowToSellCrypto:
            return false
        case .disableGUIDLogin:
            return false
        case .splitDashboard:
            return true
        }
    }
}

extension InternalFeature {

    internal var defaultsKey: String {
        "internal-flag-\(rawValue)-key"
    }

    /// The title displayed at the Debug menu.
    public var displayTitle: String {
        switch self {
        case .interestWithdrawAndDeposit:
            return "Rewards - Deposit and Withdraw"
        case .secureChannel:
            return "Secure Channel"
        case .requestConsoleLogging:
            return "Enable Network Request Console Logs"
        case .useTransactionsFlowToBuyCrypto:
            return "Buy: Uses Transactions Flow to Buy Crypto"
        case .useTransactionsFlowToSellCrypto:
            return "Sell: Uses Transactions Flow to Sell Crypto"
        case .disableGUIDLogin:
            return "Disable manual (guid) login option"
        case .splitDashboard:
            return "Split Dashboard Screen"
        }
    }
}
