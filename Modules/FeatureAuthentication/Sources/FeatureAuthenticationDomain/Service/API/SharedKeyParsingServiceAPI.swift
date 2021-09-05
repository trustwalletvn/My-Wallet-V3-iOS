// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

public enum SharedKeyParsingServiceError: Error {
    /// Invalid component count - expects a count of 2 in the format:
    case invalidComponentCount

    /// Invalid shared key length - expects `36` characters
    case invalidSharedKeyLength

    /// Password decoding failure
    case passwordDecodingFailure
}

public protocol SharedKeyParsingServiceAPI {
    /// Maps a wallet pairing code (sharedKey and password) into a `KeyDataPair`
    /// - Parameter pairingCode: the pairing code build from shared-key and password separated by a single `|`.
    /// - Returns: A `KeyDataPair` struct in which `key` is the password and `data` is the shared-key
    func parsr(pairingCode: String) -> AnyPublisher<KeyDataPair<String, String>, SharedKeyParsingServiceError>
}
