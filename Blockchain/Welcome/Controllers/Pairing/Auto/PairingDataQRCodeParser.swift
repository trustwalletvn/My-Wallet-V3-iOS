// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import Foundation
import PlatformKit
import PlatformUIKit

final class PairingDataQRCodeParser: QRCodeScannerParsing {

    // MARK: - Types

    private enum Constant {
        static let guidLength = 36
        static let componentCount = 3
        static let requiredVersion = "1"
        static let rawStringDelimiter = "|"
    }

    enum PairingCodeParsingError: Error {
        case scannerError(QRScannerError)
        case invalidComponentCount
        case invalidPairingVersion
        case invalidGuidLength
        case encryptedSharedKeyLength
    }

    // MARK: - Setup

    func parse(
        scanResult: Result<String, QRScannerError>,
        completion: ((Result<PairingData, PairingCodeParsingError>) -> Void)?
    ) {
        guard let completion = completion else {
            fatalError("completion handler must be sent to complete QR parsing")
        }
        switch scanResult {
        case .success(let rawString):
            completion(pairingData(from: rawString))
        case .failure(let error):
            completion(.failure(.scannerError(error)))
        }
    }

    /// Parse a raw string into a `PairingData` struct
    private func pairingData(from rawString: String) -> Result<PairingData, PairingCodeParsingError> {
        let components = rawString.components(separatedBy: Constant.rawStringDelimiter)
        guard components.count == Constant.componentCount else {
            return .failure(.invalidComponentCount)
        }

        // Verify version

        let version = components[0]
        guard version == Constant.requiredVersion else {
            return .failure(.invalidPairingVersion)
        }

        // Verify guid

        let guid = components[1]
        guard guid.count == Constant.guidLength else {
            return .failure(.invalidGuidLength)
        }

        // Verify shared key

        let encryptedSharedKey = components[2]
        guard !encryptedSharedKey.isEmpty else {
            return .failure(.encryptedSharedKeyLength)
        }

        return .success(
            PairingData(
                guid: guid,
                encryptedSharedKey: encryptedSharedKey
            )
        )
    }
}
