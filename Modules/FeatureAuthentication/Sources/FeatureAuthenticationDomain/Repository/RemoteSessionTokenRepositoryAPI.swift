// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public protocol RemoteSessionTokenRepositoryAPI {
    /// An `AnyPublisher` that streams the session token or `nil`
    var token: AnyPublisher<String?, SessionTokenServiceError> { get }
}
