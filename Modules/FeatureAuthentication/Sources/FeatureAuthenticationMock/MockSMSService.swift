// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain

final class MockSMSService: SMSServiceAPI {

    func request() -> AnyPublisher<Void, SMSServiceError> {
        .just(())
    }
}
