// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Supported products list for an `AssetModel`.
public enum AssetModelProduct: String, Hashable, CaseIterable {
    case privateKey = "PrivateKey"
    case mercuryDeposits = "MercuryDeposits"
    case mercuryWithdrawals = "MercuryWithdrawals"
    case interestBalance = "InterestBalance"
    case custodialWalletBalance = "CustodialWalletBalance"

    /// Indicates that this `AssetModelProduct` causes its owner currency to be enabled in the wallet app.
    fileprivate var enablesCurrency: Bool {
        switch self {
        case .custodialWalletBalance:
            return true
        default:
            return false
        }
    }
}

extension Array where Element == AssetModelProduct {
    var enablesCurrency: Bool {
        contains { element in
            element.enablesCurrency
        }
    }
}
