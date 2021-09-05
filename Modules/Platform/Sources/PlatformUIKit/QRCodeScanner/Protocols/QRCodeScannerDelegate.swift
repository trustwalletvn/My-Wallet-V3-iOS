// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

protocol QRCodeScannerDelegate: AnyObject {
    func scanComplete(with result: Result<String, QRScannerError>)
    func didStartScanning()
    func didStopScanning()
}

extension QRCodeScannerDelegate {
    func didStartScanning() {}
}
