// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol SessionTokenClientAPI: AnyObject {
    /// A Single that streams the session token
    var token: AnyPublisher<String?, NetworkError> { get }
}
