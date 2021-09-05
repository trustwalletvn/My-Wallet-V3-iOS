// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension NabuNetworkError {
    static let mockError: NabuNetworkError = .nabuError(
        NabuError(
            id: UUID().uuidString,
            code: .badMethod,
            type: .badMethod,
            description: nil
        )
    )
}
