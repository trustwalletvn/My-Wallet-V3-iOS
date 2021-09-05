// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

/// Encrypts and Decrypts Blockchain Wallet Payloads
protocol WalletPayloadCryptorAPI {

    /// Decrypts the Wallet Payload using a `KeyDataPair`
    /// - Parameters:
    ///   - pair: a `KeyDataPair` containing the decryption key and encrypted payload
    ///   - pbkdf2Iterations: the number of `PBKDF2` iterations
    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, PayloadCryptoError>

    /// Encrypts the Wallet Payload using a `KeyDataPair`
    /// - Parameters:
    ///   - pair: a `KeyDataPair` containing the encryption key and plaintext payload
    ///   - pbkdf2Iterations: the number of `PBKDF2` iterations
    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, PayloadCryptoError>
}

final class WalletPayloadCryptor: WalletPayloadCryptorAPI {

    private let payloadCrypto: PayloadCryptoAPI

    init(payloadCrypto: PayloadCryptoAPI = resolve()) {
        self.payloadCrypto = payloadCrypto
    }

    func decrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, PayloadCryptoError> {
        payloadCrypto.decrypt(data: pair.data, with: pair.key, pbkdf2Iterations: pbkdf2Iterations)
    }

    func encrypt(pair: KeyDataPair<String, String>, pbkdf2Iterations: UInt32) -> Result<String, PayloadCryptoError> {
        payloadCrypto.encrypt(data: pair.data, with: pair.key, pbkdf2Iterations: pbkdf2Iterations)
    }
}
