// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

/// Interface that exposes local JWT token which will embeded in the request's Authorization header.
/// This is used by the backend to identify logged in user.
public protocol TokenRepositoryAPI {
    var sessionToken: String? { get }
}
