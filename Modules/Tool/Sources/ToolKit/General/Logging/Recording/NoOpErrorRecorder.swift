// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class NoOpErrorRecorder: ErrorRecording {

    public init() {}

    public func error(_ error: Error) {
        // no-op
    }
}
