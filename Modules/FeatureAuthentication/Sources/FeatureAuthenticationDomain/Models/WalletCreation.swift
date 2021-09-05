// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

// MARK: Wallet Creation

/// Holds the information to create a wallet
public struct WalletCreation: Equatable {
    public let guid: String
    public let sharedKey: String
    public let password: String

    public init(guid: String, sharedKey: String, password: String) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.password = password
    }
}

/// An enum to be used for wallet creation errors
public enum WalletCreationError: LocalizedError, Equatable {
    case message(String?)
    case unknownError(String?)

    public var errorDescription: String? {
        switch self {
        case .message(let string):
            return string
        case .unknownError(let string):
            return string
        }
    }
}

/// Used to determine whether the wallet to be authenticated is new or not
public enum WalletCreationContext: Equatable {
    /// Determines the wallet created is new
    case new
    /// Determines the wallet created through recovery
    case recovery
    /// Determines the wallet already exists and it will be fetched
    case existing

    public var isNew: Bool {
        switch self {
        case .new:
            return true
        case .recovery, .existing:
            return false
        }
    }
}
