// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit

protocol CaptureSessionProtocol: AnyObject {
    var current: AVCaptureSession? { get }
    var sessionPreset: AVCaptureSession.Preset { get set }

    func startRunning()
    func stopRunning()

    func add(input: CaptureInputProtocol)
    func add(output: CaptureOutputProtocol)
}

extension AVCaptureSession: CaptureSessionProtocol {
    var current: AVCaptureSession? { self }

    func add(input: CaptureInputProtocol) {
        addInput(input.current!)
    }

    func add(output: CaptureOutputProtocol) {
        addOutput(output.current!)
    }
}
