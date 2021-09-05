// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Signifies the context of the flow
/// Typically used to report the flow in which something has happened
public enum FlowContext: String {
    case exchangeSignup = "PIT_SIGNUP"
    case kyc = "KYC"
    case settings = "SETTINGS"
    case simpleBuy = "SIMPLE_BUY"
    case walletCreation = "WALLET_CREATION"
}
