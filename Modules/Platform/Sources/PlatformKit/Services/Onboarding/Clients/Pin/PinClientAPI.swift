// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import Foundation

public typealias PinClientAPI = PinCreationClientAPI & PinValidationClientAPI

/// Serves PIN creation domain
public protocol PinCreationClientAPI {
    func create(
        pinPayload: PinPayload
    ) -> AnyPublisher<PinStoreResponse, PinStoreResponse>
}

/// Serves PIN validation domain
public protocol PinValidationClientAPI {
    /// Validate PIN
    func validate(
        pinPayload: PinPayload
    ) -> AnyPublisher<PinStoreResponse, PinStoreResponse>
}
