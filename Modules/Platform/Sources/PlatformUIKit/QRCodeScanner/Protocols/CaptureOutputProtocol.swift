// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit

protocol CaptureOutputProtocol: AnyObject {
    var current: AVCaptureOutput? { get }
}

extension AVCaptureOutput: CaptureOutputProtocol {
    var current: AVCaptureOutput? { self }
}
