// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import PlatformKit

extension AVCaptureDeviceInput {

    /// Returns an `AVCaptureDeviceInput` to be used for scanning a QR code.
    ///
    /// - Returns: the `AVCaptureDeviceInput` if available, otherwise, nil
    /// - Throws: throws an error if there are any issues with retrieving the `AVCaptureDeviceInput`
    @objc public static func deviceInputForQRScanner() throws -> AVCaptureDeviceInput {
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw AVCaptureDeviceError.failedToRetrieveDevice
        }
        do {
            return try AVCaptureDeviceInput(device: device)
        } catch {
            guard AVCaptureDevice.authorizationStatus(for: .video) == .authorized else {
                throw AVCaptureDeviceError.notAuthorized
            }
            throw AVCaptureDeviceError.inputError
        }
    }
}
