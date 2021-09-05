// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
import DIKit
import Localization
import PlatformKit

final class QRCodeScanner: NSObject, QRCodeScannerProtocol {

    static var defaultSessionQueue: DispatchQueue {
        DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.sessionQueue", qos: .background)
    }

    static var defaultCaptureQueue: DispatchQueue {
        DispatchQueue(label: "com.blockchain.Blockchain.qrCodeScanner.captureQueue")
    }

    weak var delegate: QRCodeScannerDelegate?

    let videoPreviewLayer: CALayer

    var captureVideoPreviewLayer: AVCaptureVideoPreviewLayer {
        videoPreviewLayer as! AVCaptureVideoPreviewLayer
    }

    private let captureSession: CaptureSessionProtocol
    private let captureMetadataOutput: AVCaptureMetadataOutput = .init()
    private let sessionQueue: DispatchQueue

    init?(
        deviceInput: CaptureInputProtocol? = QRCodeScanner.runDeviceInputChecks(),
        captureSession: CaptureSessionProtocol = AVCaptureSession(),
        sessionQueue: DispatchQueue = QRCodeScanner.defaultSessionQueue
    ) {
        guard let deviceInput = deviceInput else { return nil }

        captureSession.sessionPreset = .high
        self.captureSession = captureSession
        self.sessionQueue = sessionQueue

        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession.current!)
        videoPreviewLayer.videoGravity = .resizeAspectFill
        self.videoPreviewLayer = videoPreviewLayer

        super.init()

        self.sessionQueue.async { [weak self] in
            self?.configure(with: deviceInput)
        }
    }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea) {
        let frame = scannableArea.area
        sessionQueue.async { [weak self] in
            self?.captureSession.current?.commitConfiguration()
            self?.captureSession.startRunning()
            self?.captureMetadataOutput.rectOfInterest = self?.captureVideoPreviewLayer.metadataOutputRectConverted(fromLayerRect: frame) ?? .zero

            DispatchQueue.main.async {
                self?.delegate?.didStartScanning()
            }
        }
    }

    func stopReadingQRCode(complete: (() -> Void)? = nil) {
        sessionQueue.async { [weak self] in
            self?.captureSession.stopRunning()

            DispatchQueue.main.async {
                self?.delegate?.didStopScanning()
                complete?()
            }
        }
    }

    func handleSelectedQRImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else {
            handleQRImageSelectionError()
            return
        }
        let ciImage = CIImage(cgImage: cgImage)
        let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: CIContext(), options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        let stringValue = detector?.features(in: ciImage).compactMap { feature in
            (feature as? CIQRCodeFeature)?.messageString
        }.first
        guard let value = stringValue else {
            handleQRImageSelectionError()
            return
        }
        stopReadingQRCode { [weak self] in
            self?.delegate?.scanComplete(with: .success(value))
        }
    }

    // MARK: - Private methods

    private func handleQRImageSelectionError() {
        delegate?.scanComplete(with: .failure(.unknown))
    }

    private func configure(with deviceInput: CaptureInputProtocol) {
        captureSession.add(input: deviceInput)
        captureSession.add(output: captureMetadataOutput)

        let captureQueue = QRCodeScanner.defaultCaptureQueue
        captureMetadataOutput.setMetadataObjectsDelegate(self, queue: captureQueue)
        captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
    }

    // MARK: - Private static methods

    /// Check if the device input is accessible for scanning QR codes
    private static func runDeviceInputChecks(alertViewPresenter: AlertViewPresenter = resolve()) -> AVCaptureDeviceInput? {
        switch QRCodeScanner.deviceInput() {
        case .success(let deviceInput):
            return deviceInput
        case .failure(let error):
            switch error {
            case .avCaptureError(.failedToRetrieveDevice), .avCaptureError(.inputError):
                alertViewPresenter.standardError(message: String(describing: error))
            case .avCaptureError(.notAuthorized):
                alertViewPresenter.showNeedsCameraPermissionAlert()
            default:
                alertViewPresenter.standardError(message: String(describing: error))
            }
            return nil
        }
    }

    private static func deviceInput() -> Result<AVCaptureDeviceInput, QRScannerError> {
        do {
            let input = try AVCaptureDeviceInput.deviceInputForQRScanner()
            return .success(input)
        } catch {
            guard let error = error as? AVCaptureDeviceError else {
                return .failure(.unknown)
            }
            return .failure(.avCaptureError(error))
        }
    }
}

extension QRCodeScanner: AVCaptureMetadataOutputObjectsDelegate {

    // MARK: - AVCaptureMetadataOutputObjectsDelegate

    public func metadataOutput(
        _ output: AVCaptureMetadataOutput,
        didOutput metadataObjects: [AVMetadataObject],
        from connection: AVCaptureConnection
    ) {
        guard !metadataObjects.isEmpty,
              let metadataObject = metadataObjects.first,
              metadataObject.type == .qr,
              let codeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = codeObject.stringValue
        else {
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.scanComplete(with: .failure(QRScannerError.badMetadataObject))
            }
            return
        }
        stopReadingQRCode { [weak self] in
            self?.delegate?.scanComplete(with: .success(stringValue))
        }
    }
}

extension AlertViewPresenter {

    /// Displays an alert that the app requires permission to use the camera. The alert will display an
    /// action which then leads the user to their settings so that they can grant this permission.
    @objc public func showNeedsCameraPermissionAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(
                title: LocalizationConstants.Errors.cameraAccessDenied,
                message: LocalizationConstants.Errors.cameraAccessDeniedMessage,
                preferredStyle: .alert
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.goToSettings, style: .default) { _ in
                    guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
                    UIApplication.shared.open(settingsURL)
                }
            )
            alert.addAction(
                UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
            )
            self.standardNotify(alert: alert)
        }
    }
}
