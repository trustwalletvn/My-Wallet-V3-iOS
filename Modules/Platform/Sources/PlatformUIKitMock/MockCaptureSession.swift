// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
@testable import PlatformUIKit

final class CaptureSessionMock: CaptureSessionProtocol {
    var sessionPreset = AVCaptureSession.Preset.high
    var current: AVCaptureSession? = AVCaptureSession()

    var startRunningCallback: () -> Void = {}
    var startRunningCallCount: Int = 0

    func startRunning() {
        startRunningCallCount += 1
        startRunningCallback()
    }

    var stopRunningCallback: () -> Void = {}
    var stopRunningCallCount: Int = 0

    func stopRunning() {
        stopRunningCallCount += 1
        stopRunningCallback()
    }

    var addInputCallback: (CaptureInputProtocol) -> Void = { _ in }
    var inputsAdded: [CaptureInputProtocol] = []

    func add(input: CaptureInputProtocol) {
        inputsAdded.append(input)
        addInputCallback(input)
    }

    var addOutputCallback: (CaptureOutputProtocol) -> Void = { _ in }
    var outputsAdded: [CaptureOutputProtocol] = []

    func add(output: CaptureOutputProtocol) {
        outputsAdded.append(output)
        addOutputCallback(output)
    }
}
