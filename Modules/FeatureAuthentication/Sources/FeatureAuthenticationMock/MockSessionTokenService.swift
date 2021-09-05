// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockSessionTokenService: SessionTokenServiceAPI {
    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        .just(())
    }
}
