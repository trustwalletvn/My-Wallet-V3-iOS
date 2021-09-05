// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import CommonCryptoKit

public struct PinStoreKeyPairError: Error {
    let localizedDescription: String
}

/// Represents a key-value pair to be used when creating or storing a new pin code
/// in Blockchain's remote pin store.
public struct PinStoreKeyPair {
    /// String used to loop up `value`
    public let key: String

    /// String used to encrypt the user's password
    public let value: String
}

extension PinStoreKeyPair {

    public static func generateNewKeyPair() throws -> PinStoreKeyPair {
        // 32 Random bytes for key
        guard let key = Data.randomData(count: 32) else {
            throw PinStoreKeyPairError(localizedDescription: "Failed to generate key.")
        }
        // 32 Random bytes for value
        guard let value = Data.randomData(count: 32) else {
            throw PinStoreKeyPairError(localizedDescription: "Failed to generate value.")
        }
        return PinStoreKeyPair(key: key.hexValue, value: value.hexValue)
    }
}
