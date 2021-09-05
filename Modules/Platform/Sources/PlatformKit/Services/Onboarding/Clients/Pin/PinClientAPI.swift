// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

public typealias PinClientAPI = PinCreationClientAPI & PinValidationClientAPI

/// Serves PIN creation domain
public protocol PinCreationClientAPI {
    func create(pinPayload: PinPayload) -> Single<PinStoreResponse>
}

/// Serves PIN validation domain
public protocol PinValidationClientAPI {
    /// Validate PIN
    func validate(pinPayload: PinPayload) -> Single<PinStoreResponse>
}
