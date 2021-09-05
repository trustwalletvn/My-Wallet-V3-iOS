// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import ToolKit

@testable import PlatformKit

final class NabuAuthenticationExecutorMock: NabuAuthenticationExecutorAPI {

    func authenticate(
        _ networkResponsePublisher: @escaping NetworkResponsePublisher
    ) -> AnyPublisher<ServerResponse, NetworkError> {
        unimplemented()
    }
}
