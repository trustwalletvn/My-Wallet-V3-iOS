// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Useful for injecting recorders
public protocol Recordable {
    func use(recorder: Recording)
}

/// Composition of all recording types
public typealias Recording = MessageRecording & ErrorRecording & UIOperationRecording

/// Can be used to record any `String` message
public protocol MessageRecording {
    func record(_ message: String)
}

/// Can be used to record any `Error` message
public protocol ErrorRecording {
    func error(_ error: Error)
}

/// Records any illegal UI operation
public protocol UIOperationRecording {
    func recordIllegalUIOperationIfNeeded()
}
