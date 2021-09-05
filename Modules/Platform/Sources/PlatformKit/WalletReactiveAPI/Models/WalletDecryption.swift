// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// MARK: Wallet Decryption

/// Holds the necessary information for a decrypted wallet
public struct WalletDecryption: Equatable {
    public let guid: String?
    public let sharedKey: String?
    public let passwordPartHash: String?

    public init(guid: String?, sharedKey: String?, passwordPartHash: String?) {
        self.guid = guid
        self.sharedKey = sharedKey
        self.passwordPartHash = passwordPartHash
    }
}
