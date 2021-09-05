// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit

public final class SecureChannelQRCodeParser: QRCodeScannerParsing {

    // MARK: Types

    enum ScannerError: LocalizedError {
        case qrCodeIsNotSecureChannel

        var errorDescription: String? {
            switch self {
            case .qrCodeIsNotSecureChannel:
                return "Invalid QR Code."
            }
        }
    }

    // MARK: Private Properties

    private let secureChannelService: SecureChannelAPI

    // MARK: Init

    public init(secureChannelService: SecureChannelAPI = resolve()) {
        self.secureChannelService = secureChannelService
    }

    // MARK: QRCodeScannerParsing

    public func parse(scanResult: Result<String, QRScannerError>, completion: ((Result<String, Error>) -> Void)?) {
        switch scanResult {
        case .failure(let error):
            completion?(.failure(error))
        case .success(let string):
            if secureChannelService.isPairingQRCode(msg: string) {
                // Scanned QR Code
                completion?(.success(string))
            } else {
                // Scanned incorrect QR code.
                completion?(.failure(ScannerError.qrCodeIsNotSecureChannel))
            }
        }
    }
}
