// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ToolKit

final class NoOpErrorRecoder: ErrorRecording {

    func error(_ error: Error) {
        // no-op
    }
}
