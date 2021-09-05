// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol WalletPairingFetcherAPI: AnyObject {
    /// Pairs the wallet and decrypt it using a password provided by the user
    /// - Parameters: password: the password used for wallet decryption
    func authenticate(using password: String)
}
