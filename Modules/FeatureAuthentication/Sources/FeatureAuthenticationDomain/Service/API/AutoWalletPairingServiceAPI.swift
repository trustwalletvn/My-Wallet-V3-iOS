// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public enum AutoWalletPairingServiceError: Error {
    case networkError(NetworkError)
    case walletCryptoServiceError(Error)
    case parsingError(SharedKeyParsingServiceError)
    case walletPayloadServiceError(WalletPayloadServiceError)
}

/// A service API for auto pairing
public protocol AutoWalletPairingServiceAPI: AnyObject {
    /// Maps a QR pairing code of a wallet into its password.
    func pair(using pairingData: PairingData) -> AnyPublisher<String, AutoWalletPairingServiceError>
    /// Gets encryptionPhrase
    func encryptionPhrase(using guid: String) -> AnyPublisher<String, AutoWalletPairingServiceError>
}
