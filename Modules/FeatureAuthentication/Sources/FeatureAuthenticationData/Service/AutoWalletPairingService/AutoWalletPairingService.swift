// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureAuthenticationDomain
import ToolKit
import WalletPayloadKit

/// A service that is responsible for the auto pairing process
public final class AutoWalletPairingService: AutoWalletPairingServiceAPI {

    // MARK: - Type

    public typealias WalletRepositoryAPI = GuidRepositoryAPI &
        SessionTokenRepositoryAPI &
        SharedKeyRepositoryAPI &
        LanguageRepositoryAPI &
        SyncPubKeysRepositoryAPI &
        AuthenticatorRepositoryAPI &
        PayloadRepositoryAPI

    // MARK: - Properties

    private let walletCryptoService: WalletCryptoServiceAPI
    private let parsingService = SharedKeyParsingService()

    private let walletPairingClient: AutoWalletPairingClientAPI
    private let walletPayloadService: WalletPayloadServiceAPI

    // MARK: - Setup

    public init(
        repository: WalletRepositoryAPI,
        walletPayloadClient: WalletPayloadClientAPI = resolve(),
        walletPairingClient: AutoWalletPairingClientAPI = resolve(),
        walletCryptoService: WalletCryptoServiceAPI = resolve()
    ) {
        self.walletPairingClient = walletPairingClient
        walletPayloadService = WalletPayloadService(
            client: walletPayloadClient,
            repository: repository
        )
        self.walletCryptoService = walletCryptoService
    }

    /// Maps a QR pairing code of a wallet into its password, retrieve and cache the wallet data.
    /// Finally returns the password of the wallet
    /// 1. Receives a pairing code (guid, encrypted shared-key)
    /// 2. Sends the wallet `guid` -> receives a passphrase that can be used to decrypt the shared key.
    /// 3. Decrypt the shared key
    /// 4. Parse the shared key and the password
    /// 5. Request the wallet payload using the wallet GUID and the shared key
    /// 6. Returns the password.
    /// - Parameter pairingData: A pairing code comprises GUID and an encrypted shared key.
    /// - Returns: The wallet password - decrypted and ready for usage.
    public func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        walletPairingClient
            .request(guid: pairingData.guid)
            .mapError(AutoWalletPairingServiceError.networkError)
            .map {
                KeyDataPair<String, String>(
                    key: $0,
                    data: pairingData.encryptedSharedKey
                )
            }
            .flatMap { [walletCryptoService] keyDataPair -> AnyPublisher<String, AutoWalletPairingServiceError> in
                walletCryptoService.decrypt(pair: keyDataPair, pbkdf2Iterations: WalletCryptoPBKDF2Iterations.autoPair)
                    .asPublisher()
                    .mapError(AutoWalletPairingServiceError.walletCryptoServiceError)
                    .eraseToAnyPublisher()
            }
            .map { [parsingService] pairingCode
                -> Result<KeyDataPair<String, String>, AutoWalletPairingServiceError> in
                parsingService.parse(pairingCode: pairingCode)
                    .mapError(AutoWalletPairingServiceError.parsingError)
            }
            .flatMap { [walletPayloadService] pairResult
                -> AnyPublisher<String, AutoWalletPairingServiceError> in
                switch pairResult {
                case .success(let pair):
                    return walletPayloadService.request(
                        guid: pairingData.guid,
                        sharedKey: pair.data
                    )
                    .map { _ in pair.key }
                    .mapError(AutoWalletPairingServiceError.walletCryptoServiceError)
                    .eraseToAnyPublisher()
                case .failure(let error):
                    return .failure(error)
                }
            }
            .eraseToAnyPublisher()
    }

    public func encryptionPhrase(using guid: String) -> AnyPublisher<String, AutoWalletPairingServiceError> {
        walletPairingClient.request(guid: guid)
            .mapError(AutoWalletPairingServiceError.networkError)
            .eraseToAnyPublisher()
    }
}
