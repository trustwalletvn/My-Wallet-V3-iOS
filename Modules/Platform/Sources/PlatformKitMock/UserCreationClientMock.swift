// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit
import ToolKit

@testable import PlatformKit

final class UserCreationClientMock: UserCreationClientAPI {

    var expectedResult: Result<NabuOfflineTokenResponse, NetworkError>!

    func createUser(
        for jwtToken: String
    ) -> AnyPublisher<NabuOfflineTokenResponse, NetworkError> {
        expectedResult.publisher
    }
}
