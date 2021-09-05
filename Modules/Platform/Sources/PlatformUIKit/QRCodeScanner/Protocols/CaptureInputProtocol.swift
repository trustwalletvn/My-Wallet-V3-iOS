// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit

protocol CaptureInputProtocol: AnyObject {
    var current: AVCaptureInput? { get }
}

extension AVCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput? { self }
}
