// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

public typealias NetworkResponsePublisher =
    (String) -> AnyPublisher<ServerResponse, NetworkError>

public protocol AuthenticatorAPI: AnyObject {

    /// Fetches authentication token
    /// - Parameter responseProvider: method requiring authentication token
    func authenticate(
        _ responseProvider: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkError>
}
