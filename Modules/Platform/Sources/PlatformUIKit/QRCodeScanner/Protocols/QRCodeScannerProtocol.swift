// Copyright © Blockchain Luxembourg S.A. All rights reserved.

protocol QRCodeScannerProtocol: AnyObject {
    var videoPreviewLayer: CALayer { get }
    var delegate: QRCodeScannerDelegate? { get set }

    func startReadingQRCode(from scannableArea: QRCodeScannableArea)
    func stopReadingQRCode(complete: (() -> Void)?)
    func handleSelectedQRImage(_ image: UIImage)
}
