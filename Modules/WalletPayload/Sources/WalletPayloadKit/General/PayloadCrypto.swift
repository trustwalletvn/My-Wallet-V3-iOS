// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import DIKit
import Foundation

enum PayloadCryptoError: Error {
    case unknown
    case noEncryptedWalletData
    case noPassword
    case keyDerivationFailed
    case decodingFailed
    case unsupportedPayloadVersion
    case encryptionFailed
    case decryptionFailed
    case failedToDecryptV1Payload
}

struct WalletData {
    let payload: WalletPayloadWrapper
    let password: String
}

struct WalletV1Data {
    let payload: String
    let password: String
}

protocol PayloadCryptoAPI {

    /// Decrypts a base64 encoded payload
    /// - Parameters:
    ///   - dataBase64String: a base64 encoded payload string
    ///   - key: the decryption key
    ///   - iterations: the number PBKDF2 iterations
    /// This method uses the `AES.CBC` block mode and `ISO10126` padding
    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError>

    /// Decrypts a base64 encoded payload
    /// - Parameters:
    ///   - dataBase64String: a base64 encoded payload string
    ///   - key: the decryption key
    ///   - iterations: the number PBKDF2 iterations
    ///   - options: the specific `AES` block mode and padding type to be used
    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32,
        options: AESOptions
    ) -> Result<String, PayloadCryptoError>

    /// Encrypts UTF-8 encoded payload
    /// - Parameters:
    ///   - payload: a UTF-8 encoded payload string
    ///   - key: the encryption key
    ///   - iterations: the number PBKDF2 iterations
    /// This method uses the `AES.CBC` block mode and `ISO10126` padding
    func encrypt(
        data payload: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError>

    /// Decrypts `V1`, `V2`, and `V3` wallet payloads
    /// - Parameters:
    ///   - encryptedWalletData: the encrypted wallet payload string
    ///   - password: the wallet payload decryption password
    func decryptWallet(encryptedWalletData: String, password: String) -> Result<String, PayloadCryptoError>
}

extension PayloadCryptoAPI {

    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        decrypt(
            data: dataBase64String,
            with: key,
            pbkdf2Iterations: iterations,
            options: AESOptions.default
        )
    }
}

final class PayloadCrypto: PayloadCryptoAPI {

    private enum Constants {
        static let supportedEncryptionVersion = 4
        static let saltBytes = 16
        static let keyBitLen: UInt = 256
        static let blockBitLen = 128
    }

    private let cryptor: AESCryptorAPI

    init(cryptor: AESCryptorAPI = resolve()) {
        self.cryptor = cryptor
    }

    func decrypt(
        data dataBase64String: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32,
        options: AESOptions = .default
    ) -> Result<String, PayloadCryptoError> {
        guard iterations > 0 else {
            fatalError("Invalid iteration count")
        }

        guard let data = Data(base64Encoded: dataBase64String) else {
            return .failure(.decodingFailed)
        }

        let iv = Array(data.bytes[0..<Constants.saltBytes])
        let payload = Array(data.bytes[Constants.saltBytes..<data.count])

        // AES initialization vector is also used as the salt in password stretching
        let salt = iv

        return stretchPassword(
            password: key,
            salt: salt,
            iterations: iterations,
            keyLengthBytes: Constants.keyBitLen
        )
        .flatMap { stretchedPassword -> Result<String, PayloadCryptoError> in
            decrypt(buffer: payload, with: stretchedPassword.bytes, iv: iv, options: options)
        }
    }

    func encrypt(
        data payload: String,
        with key: String,
        pbkdf2Iterations iterations: UInt32
    ) -> Result<String, PayloadCryptoError> {
        guard iterations > 0 else {
            fatalError("Invalid iteration count")
        }

        let salt = PayloadCrypto.randomIV(Constants.saltBytes)
        return stretchPassword(
            password: key,
            salt: salt,
            iterations: iterations,
            keyLengthBytes: Constants.keyBitLen
        )
        .flatMap { key -> Result<String, PayloadCryptoError> in
            encrypt(data: payload, with: key, iv: salt)
        }
    }

    func decryptWallet(encryptedWalletData: String, password: String) -> Result<String, PayloadCryptoError> {
        decryptWalletSync(data: encryptedWalletData, password: password)
    }

    // MARK: - Private methods

    private func encrypt(data: String, with key: Data, iv: [UInt8]) -> Result<String, PayloadCryptoError> {
        guard let dataBytes = data.data(using: .utf8) else {
            fatalError(PayloadCryptoError.encryptionFailed.localizedDescription)
        }
        return cryptor.encrypt(
            data: dataBytes,
            with: key,
            iv: Data(iv)
        )
        .replaceError(with: PayloadCryptoError.encryptionFailed)
        .map { encryptedBytes -> String in
            Data(iv + encryptedBytes).base64EncodedString()
        }
    }

    private func stretchPassword(password: String, salt: [UInt8], iterations: UInt32, keyLengthBytes: UInt) -> Result<Data, PayloadCryptoError> {
        let keyLenBytes = (keyLengthBytes | 256) / 8
        let saltData = Data(salt)
        return PBKDF2.deriveSHA1Result(
            password: password,
            salt: saltData,
            iterations: iterations,
            keySizeBytes: keyLenBytes
        )
        .replaceError(with: .keyDerivationFailed)
    }

    private func decrypt(buffer: [UInt8], with key: [UInt8], iv: [UInt8], options: AESOptions = .default) -> Result<String, PayloadCryptoError> {
        let data = Data(buffer)
        let keyData = Data(key)
        let ivData = Data(iv)
        return cryptor.decryptUTF8String(
            data: data,
            with: keyData,
            iv: ivData,
            options: options
        )
        .replaceError(with: .decryptionFailed)
    }

    private func decryptWalletSync(data: String, password: String) -> Result<String, PayloadCryptoError> {
        PayloadDecoder().decode(wrapper: data)
            .replaceError(with: .decodingFailed)
            .flatMap { wrapper -> Result<String, PayloadCryptoError> in
                validateAndDecryptV2V3(wrapper: wrapper, password: password)
            }
            .flatMapError { _ -> Result<String, PayloadCryptoError> in
                decryptV1(wallet:
                    WalletV1Data(
                        payload: data,
                        password: password
                    )
                )
            }
    }

    private func validateAndDecryptV2V3(wrapper: WalletPayloadWrapper, password: String) -> Result<String, PayloadCryptoError> {
        validatePayloadVersion(
            wallet: WalletData(
                payload: wrapper,
                password: password
            )
        )
        .flatMap { wallet -> Result<String, PayloadCryptoError> in
            decryptV2V3V4(wallet: wallet)
        }
    }

    private func validatePayloadVersion(wallet: WalletData) -> Result<WalletData, PayloadCryptoError> {
        guard wallet.payload.version <= Constants.supportedEncryptionVersion else {
            return .failure(.unsupportedPayloadVersion)
        }
        return .success(wallet)
    }

    /// `V2`/ `V3` / `V4`: `CBC`, `ISO10126`, iterations in wrapper
    private func decryptV2V3V4(wallet: WalletData) -> Result<String, PayloadCryptoError> {
        decrypt(
            data: wallet.payload.payload,
            with: wallet.password,
            pbkdf2Iterations: wallet.payload.pbkdf2IterationCount
        )
    }

    private func decryptV1(wallet: WalletV1Data) -> Result<String, PayloadCryptoError> {

        /// `V1`: `CBC`, `ISO10126`, `10` iterations
        func CBC_ISO10126_10Iterations(_ data: String, _ password: String) -> Result<String, PayloadCryptoError> {
            decrypt(data: data, with: password, pbkdf2Iterations: 10)
        }

        /// `V1`: OFB, nopad, 1 iteration
        func OFB_NoPading_1Iterations(_ data: String, _ password: String) -> Result<String, PayloadCryptoError> {
            decrypt(
                data: data,
                with: password,
                pbkdf2Iterations: 1,
                options: AESOptions(
                    blockMode: .OFB,
                    padding: .noPadding
                )
            )
        }

        /// `V1`: `OFB`, `ISO7816`, `1` iteration
        /// `ISO/IEC 9797-1` Padding method `2` is the same as `ISO/IEC 7816-4:2005`
        func OFB_ISO78164_1Iterations(_ data: String, _ password: String) -> Result<String, PayloadCryptoError> {
            decrypt(
                data: data,
                with: password,
                pbkdf2Iterations: 1,
                options: AESOptions(
                    blockMode: .OFB,
                    padding: .iso78164
                )
            )
        }

        /// `V1`: `CBC`, `ISO10126`, `1` iterations
        func CBC_ISO10126_1Iterations(_ data: String, _ password: String) -> Result<String, PayloadCryptoError> {
            decrypt(data: data, with: password, pbkdf2Iterations: 1)
        }

        let functions = [
            CBC_ISO10126_10Iterations,
            OFB_NoPading_1Iterations,
            OFB_ISO78164_1Iterations,
            CBC_ISO10126_1Iterations
        ]

        for function in functions {
            if case .success(let decrypted) = function(wallet.payload, wallet.password) {
                return .success(decrypted)
            }
        }

        return .failure(.failedToDecryptV1Payload)
    }

    private static func randomIV(_ count: Int) -> [UInt8] {
        (0..<count).map { _ in UInt8.random(in: 0...UInt8.max) }
    }
}
