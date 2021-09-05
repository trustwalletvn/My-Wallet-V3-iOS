// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AVKit
@testable import PlatformUIKit

final class MockCaptureInput: CaptureInputProtocol {
    var current: AVCaptureInput?
}
