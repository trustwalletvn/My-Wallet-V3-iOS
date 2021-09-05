// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit
import DIKit
import RxSwift

public protocol SecureChannelAPI: AnyObject {
    func isPairingQRCode(msg: String) -> Bool
    func onQRCodeScanned(msg: String) -> Completable
    func isReadyForSecureChannel() -> Single<Bool>
    func didAcceptSecureChannel(details: SecureChannelConnectionDetails) -> Completable
    func didRejectSecureChannel(details: SecureChannelConnectionDetails) -> Completable
    /// Creates a `SecureChannelConnectionCandidate` from the given `userInfo` notification payload.
    /// - Parameter userInfo: Received notification payload.
    /// - Returns: Single that emits a `SecureChannelConnectionCandidate` object or nil if the payload is malformed or the browser identity is unknown.
    func createSecureChannelConnectionCandidate(_ userInfo: [AnyHashable: Any]) -> Single<SecureChannelConnectionCandidate>
}

final class SecureChannelService: SecureChannelAPI {

    // MARK: Types

    enum SecureChannelError: LocalizedError {
        case missingGUID
        case missingSharedKey
        case missingPassword
        case malformedPayload
        case ipMismatch
        case cantValidateIP
        case connectionExpired

        var errorDescription: String? {
            switch self {
            case .cantValidateIP:
                return "Secure Channel: Unable to validate IP."
            case .ipMismatch:
                return "Secure Channel: IP doesn't match."
            case .malformedPayload:
                return "Secure Channel: Malformed payload."
            case .missingGUID:
                return "Secure Channel: Missing GUID."
            case .missingPassword:
                return "Secure Channel: Missing password."
            case .missingSharedKey:
                return "Secure Channel: Missing shared key."
            case .connectionExpired:
                return "Secure Channel: Connection expired."
            }
        }
    }

    // MARK: Private Properties

    private let browserIdentityService: BrowserIdentityService
    private let secureChannelNetwork: SecureChannelClientAPI
    private let walletRepository: WalletRepositoryAPI
    private let messageService: SecureChannelMessageService

    // MARK: Init

    init(
        browserIdentityService: BrowserIdentityService = resolve(),
        messageService: SecureChannelMessageService = resolve(),
        secureChannelNetwork: SecureChannelClientAPI = resolve(),
        walletRepository: WalletRepositoryAPI = resolve()
    ) {
        self.browserIdentityService = browserIdentityService
        self.messageService = messageService
        self.secureChannelNetwork = secureChannelNetwork
        self.walletRepository = walletRepository
    }

    // MARK: - SecureChannelAPI

    func isPairingQRCode(msg: String) -> Bool {
        decodePairingCode(payload: msg) != nil
    }

    func createSecureChannelConnectionCandidate(_ userInfo: [AnyHashable: Any]) -> Single<SecureChannelConnectionCandidate> {
        guard let details = SecureChannelConnectionDetails(userInfo) else {
            return .error(SecureChannelError.malformedPayload)
        }
        return browserIdentityService.getBrowserIdentity(pubKeyHash: details.pubkeyHash)
            .eraseError()
            .flatMap { browserIdentity -> Result<(SecureChannelConnectionCandidate, BrowserIdentity), Error> in
                decryptMessage(details.messageRawEncrypted, pubKeyHash: details.pubkeyHash)
                    .map { message -> SecureChannelConnectionCandidate in
                        SecureChannelConnectionCandidate(
                            details: details,
                            isAuthorized: browserIdentity.authorized,
                            timestamp: message.timestamp,
                            lastUsed: browserIdentity.lastUsed
                        )
                    }
                    .map { candidate in
                        (candidate, browserIdentity)
                    }
            }
            .single
            .flatMap(weak: self) { (self, data) -> Single<SecureChannelConnectionCandidate> in
                let (candidate, browserIdentity) = data
                return self.shouldAcceptSecureChannel(details: details, candidate: candidate, browserIdentity: browserIdentity)
                    .andThen(Single.just(candidate))
            }
    }

    func isReadyForSecureChannel() -> Single<Bool> {
        Single.zip(walletRepository.hasGuid, walletRepository.hasSharedKey, walletRepository.hasPassword)
            .map { hasGuid, hasSharedKey, hasPassword in
                hasGuid && hasSharedKey && hasPassword
            }
            .catchErrorJustReturn(false)
    }

    func didAcceptSecureChannel(details: SecureChannelConnectionDetails) -> Completable {
        browserIdentityService.addBrowserIdentityAuthorization(pubKeyHash: details.pubkeyHash, authorized: true)
            .flatMap {
                browserIdentityService.updateBrowserIdentityUsedTimestamp(pubKeyHash: details.pubkeyHash)
            }
            .eraseError()
            .flatMap {
                decryptMessage(details.messageRawEncrypted, pubKeyHash: details.pubkeyHash)
            }
            .single
            .flatMapCompletable(weak: self) { (self, message) in
                self.sendLoginMessage(channelId: message.channelId, pubKeyHash: details.pubkeyHash)
            }
    }

    func onQRCodeScanned(msg: String) -> Completable {
        guard let pairingCode = decodePairingCode(payload: msg) else {
            preconditionFailure("Not a pairing code.")
        }
        return sendHandshake(pairingCode: pairingCode)
    }

    func didRejectSecureChannel(details: SecureChannelConnectionDetails) -> Completable {
        decryptMessage(details.messageRawEncrypted, pubKeyHash: details.pubkeyHash)
            .single
            .flatMapCompletable(weak: self) { (self, message) in
                self.sendMessage(
                    SecureChannel.EmptyResponse(),
                    channelId: message.channelId,
                    pubKeyHash: details.pubkeyHash,
                    success: false
                )
                .andThen(self.browserIdentityService.deleteBrowserIdentity(pubKeyHash: details.pubkeyHash).completable)
            }
    }

    // MARK: - Private Methods

    private func shouldAcceptSecureChannel(
        details: SecureChannelConnectionDetails,
        candidate: SecureChannelConnectionCandidate,
        browserIdentity: BrowserIdentity
    ) -> Completable {
        validateTimestamp(candidate: candidate)
            .andThen(validateIPAddress(details: details, browserIdentity: browserIdentity))
    }

    private func validateTimestamp(candidate: SecureChannelConnectionCandidate) -> Completable {
        Completable.create { observer -> Disposable in
            let fiveMinutesAgo = Date(timeIntervalSinceNow: -5 * 60)
            if candidate.timestamp >= fiveMinutesAgo {
                observer(.completed)
            } else {
                observer(.error(SecureChannelError.connectionExpired))
            }
            return Disposables.create()
        }
    }

    private func validateIPAddress(details: SecureChannelConnectionDetails, browserIdentity: BrowserIdentity) -> Completable {
        guard !browserIdentity.authorized else {
            // IP Check only applies to new connections.
            return .empty()
        }
        return secureChannelNetwork.getIp()
            .catchError { _ in
                throw SecureChannelError.cantValidateIP
            }
            .map { ip in
                guard details.originIP == ip else {
                    throw SecureChannelError.ipMismatch
                }
            }
            .asCompletable()
    }

    private func decodePairingCode(payload: String) -> SecureChannel.PairingCode? {
        guard let data = payload.data(using: .utf8) else {
            return nil
        }
        return try? JSONDecoder().decode(SecureChannel.PairingCode.self, from: data)
    }

    private func sendHandshake(pairingCode: SecureChannel.PairingCode) -> Completable {
        let browserIdentity = BrowserIdentity(pubKey: pairingCode.pubkey)
        return browserIdentityService
            .addBrowserIdentity(identity: browserIdentity)
            .single
            .flatMap(weak: self) { (self, _) -> Single<String?> in
                self.walletRepository.guid
            }
            .map { guid -> SecureChannel.PairingHandshake in
                guard let guid = guid else {
                    throw SecureChannelError.missingGUID
                }
                return SecureChannel.PairingHandshake(guid: guid)
            }
            .flatMapCompletable(weak: self) { (self, handshake) in
                self.sendMessage(
                    handshake,
                    channelId: pairingCode.channelId,
                    pubKeyHash: browserIdentity.pubKeyHash,
                    success: true
                )
            }
    }

    private func sendLoginMessage(channelId: String, pubKeyHash: String) -> Completable {
        Single.zip(walletRepository.guid, walletRepository.sharedKey, walletRepository.password)
            .map { guid, sharedKey, password -> (guid: String, sharedKey: String, password: String) in
                guard let guid = guid else {
                    throw SecureChannelError.missingGUID
                }
                guard let sharedKey = sharedKey else {
                    throw SecureChannelError.missingSharedKey
                }
                guard let password = password else {
                    throw SecureChannelError.missingPassword
                }
                return (guid, sharedKey, password)
            }
            .map { guid, sharedKey, password in
                SecureChannel.LoginMessage(guid: guid, password: password, sharedKey: sharedKey)
            }
            .flatMapCompletable(weak: self) { (self, message) in
                self.sendMessage(
                    message,
                    channelId: channelId,
                    pubKeyHash: pubKeyHash,
                    success: true
                )
            }
    }

    private func decryptMessage(
        _ message: String,
        pubKeyHash: String
    ) -> Result<SecureChannel.BrowserMessage, Error> {
        browserIdentityService.getBrowserIdentity(pubKeyHash: pubKeyHash)
            .eraseError()
            .flatMap { browserIdentity in
                let deviceKey = browserIdentityService.getDeviceKey()
                return messageService
                    .decryptMessage(
                        message,
                        publicKey: Data(hex: browserIdentity.pubKey),
                        deviceKey: deviceKey
                    )
                    .eraseError()
            }
    }

    private func sendMessage<Message: Encodable>(
        _ message: Message,
        channelId: String,
        pubKeyHash: String,
        success: Bool
    ) -> Completable {
        browserIdentityService.getBrowserIdentity(pubKeyHash: pubKeyHash)
            .eraseError()
            .flatMap { browserIdentity -> Result<SecureChannel.PairingResponse, Error> in
                let deviceKey = browserIdentityService.getDeviceKey()
                return messageService.buildMessage(
                    message: message,
                    channelId: channelId,
                    success: success,
                    publicKey: Data(hex: browserIdentity.pubKey),
                    deviceKey: deviceKey
                )
                .eraseError()
            }
            .single
            .flatMapCompletable(weak: self) { (self, response) -> Completable in
                self.secureChannelNetwork.sendMessage(msg: response)
            }
    }
}
