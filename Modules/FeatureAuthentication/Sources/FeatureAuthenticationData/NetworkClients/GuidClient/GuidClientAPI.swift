// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

/// A `GUID` client/service API. A concrete type is expected to fetch the `GUID`
public protocol GuidClientAPI: AnyObject {
    /// An `AnyPublisher` that streams the `GUID` on success or fails due
    /// to network error.
    func guid(by sessionToken: String) -> AnyPublisher<String?, NetworkError>
}
