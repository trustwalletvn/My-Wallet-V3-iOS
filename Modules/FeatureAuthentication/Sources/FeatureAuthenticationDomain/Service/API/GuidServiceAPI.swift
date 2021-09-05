// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

// MARK: - Types

public enum GuidServiceError: Error {
    case missingSessionToken
    case missingGuid
    case networkError(NetworkError)
}

public protocol GuidServiceAPI: AnyObject {
    /// An `AnyPublisher` that streams the `GUID` on success or fails due
    /// to a missing resource or network error.
    var guid: AnyPublisher<String, GuidServiceError> { get }
}
