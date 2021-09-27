// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Embeds any nesting types: e.g topics and types of notifications
public enum RemoteNotification {
    /// A data bag for push notification format
    public enum NotificationType {

        // MARK: - Cases

        /// Received bitcoin transaction
        case bitcoinTransactionReceived

        // TODO: Delete this once the type logic is handled (parsing & generalizing)
        case general

        // MARK: - Setup

        // TODO: Parse data into readable format. Consider creating a parser to do it
        init(using info: [String: Any]) {
            self = .general
        }
    }

    // TODO: Add topics here
    public enum Topic: String {
        case todo = "todo_topics"
    }

    /// Remote notification token representation
    public typealias Token = String

    /// Potential errors during token fetching
    public enum TokenFetchError: Error {

        /// Embeds any firebase error
        case external(Error)

        /// Token is empty
        case tokenIsEmpty

        /// Result is nullified
        case resultIsNil
    }
}
