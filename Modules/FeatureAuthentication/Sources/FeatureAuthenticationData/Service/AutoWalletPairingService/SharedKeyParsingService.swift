// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import CommonCryptoKit
import FeatureAuthenticationDomain
import Foundation
import ToolKit

/// A shared key parsing service
final class SharedKeyParsingService {

    // MARK: - Types

    private enum Constant {
        static let componentCount = 2
        static let sharedKeyLength = 36
        static let delimiter: Character = "|"
    }

    func parse(pairingCode: String) -> Result<KeyDataPair<String, String>, SharedKeyParsingServiceError> {
        let components = pairingCode.split(separator: Constant.delimiter)
        guard components.count == Constant.componentCount else {
            return .failure(.invalidComponentCount)
        }

        // Extract shared key
        let sharedKey = String(components[0])
        guard sharedKey.count == Constant.sharedKeyLength else {
            return .failure(.invalidSharedKeyLength)
        }

        // Extract password
        let hexEncodedPassword = String(components[1])
        let passwordData = Data(hex: hexEncodedPassword)
        guard let password = String(data: passwordData, encoding: .utf8) else {
            return .failure(.passwordDecodingFailure)
        }

        // Construct a `KeyDataPair` from the password and the shared key
        return .success(KeyDataPair(key: password, data: sharedKey))
    }
}
