// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
@testable import FeatureAuthenticationDomain
import RxSwift

final class MockEmailAuthorizationService: EmailAuthorizationServiceAPI {

    var authorize = Completable.empty()

    func cancel() {}

    func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError> {
        .just(())
    }
}
