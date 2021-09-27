// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

@testable import PlatformKit

final class NabuResetUserClientMock: NabuResetUserClientAPI {

    var expectedResult: Result<Void, NetworkError>!

    func resetUser(
        offlineToken: NabuOfflineTokenResponse,
        jwt: String
    ) -> AnyPublisher<Void, NetworkError> {
        expectedResult.publisher.eraseToAnyPublisher()
    }
}
