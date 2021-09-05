// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain

final class NoOpSessionTokenService: SessionTokenServiceAPI {

    func setupSessionToken() -> AnyPublisher<Void, SessionTokenServiceError> {
        Deferred {
            Future { _ in
                // no-op
            }
        }
        .eraseToAnyPublisher()
    }
}
