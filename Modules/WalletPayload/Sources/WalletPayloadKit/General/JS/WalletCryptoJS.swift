// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import JavaScriptCore
import Localization
import ToolKit

extension Notification.Name {
    public static let walletInitialized = Notification.Name("notification_wallet_initialized")
    public static let walletMetadataLoaded = Notification.Name("notification_wallet_metadata_loaded")
}

@objc public class WalletCryptoJS: NSObject {

    typealias CryptoResultToJSMapper = (Result<String, PayloadCryptoError>) -> String

    private let payloadCrypto: PayloadCryptoAPI
    private let decryptionMapper: CryptoResultToJSMapper

    @objc override public convenience init() {
        self.init(
            payloadCrypto: resolve(),
            decryptionMapper: { decryptionResult in
                decryptionResult.walletCryptoResultJSON
            }
        )
    }

    init(payloadCrypto: PayloadCryptoAPI, decryptionMapper: @escaping CryptoResultToJSMapper) {
        self.payloadCrypto = payloadCrypto
        self.decryptionMapper = decryptionMapper
        super.init()
    }

    @objc public func setup(with context: JSContext) {
        context.setJsFn2Pure(named: "objc_decrypt_wallet" as NSString) { [weak self] encryptedWalletData, password -> Any in
            self?.decryptWallet(
                encryptedWalletData: encryptedWalletData,
                password: password
            ) ?? PayloadCryptoError.unknown.walletCryptoResult
        }

        context.setJsFn0(named: "objc_set_is_initialized" as NSString) {
            let walletInitializedNotification = Notification(name: .walletInitialized)
            NotificationCenter.default.post(walletInitializedNotification)
        }

        context.setJsFn0(named: "objc_metadata_loaded" as NSString) {
            let walletMetadataLoadedNotification = Notification(name: .walletMetadataLoaded)
            NotificationCenter.default.post(walletMetadataLoadedNotification)
        }
    }

    private func decryptWallet(encryptedWalletData data: JSValue, password pw: JSValue) -> String {
        guard let encryptedWalletData = data.toString() else {
            return decryptionMapper(.failure(.noEncryptedWalletData))
        }
        guard let password = pw.toString() else {
            return decryptionMapper(.failure(.noPassword))
        }
        return payloadCrypto.decryptWallet(
            encryptedWalletData: encryptedWalletData,
            password: password
        )
        .reduce(decryptionMapper)
    }
}

extension Result where Success == String, Failure == PayloadCryptoError {

    fileprivate var walletCryptoResultJSON: String {
        walletCryptoResult.encodedJSON
    }

    private var walletCryptoResult: WalletCryptoResult {
        switch self {
        case .success(let decryptedWallet):
            return WalletCryptoResult(success: decryptedWallet)
        case .failure(let error):
            return error.walletCryptoResult
        }
    }
}

extension PayloadCryptoError {

    fileprivate var walletCryptoResult: WalletCryptoResult {
        WalletCryptoResult(failure: localisedErrorMessage)
    }

    private var localisedErrorMessage: String {
        switch self {
        case .decryptionFailed:
            return LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
        default:
            return LocalizationConstants.WalletPayloadKit.Error.unknown
        }
    }
}

private struct WalletCryptoResult: Codable {

    var encodedJSON: String {
        // swiftlint:disable:next force_try
        try! encodeToString(encoding: .utf8)
    }

    let success: String?
    let failure: String?

    init(success: String) {
        self.success = success
        failure = nil
    }

    init(failure: String) {
        success = nil
        self.failure = failure
    }
}
