// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Protocol description for a log statement destination (e.g. console, file, remote, etc.)
public protocol LogDestination {

    /// Logs a statement to this destination.
    ///
    /// - Parameters:
    ///   - statement: the statement to log
    func log(statement: String, level: LogLevel)
}
