// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxSwift

@testable import PlatformKit

struct MockPinClient: PinClientAPI {
    private var response: PinStoreResponse {
        PinStoreResponse(
            statusCode: statusCode,
            error: error,
            remaining: remaining,
            pinDecryptionValue: "pin decryption value",
            key: "key",
            value: "value"
        )
    }

    private let statusCode: PinStoreResponse.StatusCode?
    private let error: String?
    private let remaining: Int?

    init(
        statusCode: PinStoreResponse.StatusCode?,
        error: String? = nil,
        remaining: Int? = nil
    ) {
        self.statusCode = statusCode
        self.error = error
        self.remaining = remaining
    }

    func create(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        .just(response)
    }

    func validate(pinPayload: PinPayload) -> Single<PinStoreResponse> {
        .just(response)
    }
}
