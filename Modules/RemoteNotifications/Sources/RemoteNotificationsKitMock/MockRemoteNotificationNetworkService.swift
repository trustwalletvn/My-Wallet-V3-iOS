// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import RxSwift

@testable import RemoteNotificationsKit

final class MockRemoteNotificationNetworkService: RemoteNotificationNetworkServicing {
    let expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>

    init(expectedResult: Result<Void, RemoteNotificationNetworkService.PushNotificationError>) {
        self.expectedResult = expectedResult
    }

    func register(
        with deviceToken: String,
        sharedKeyProvider: SharedKeyRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) -> Single<Void> {
        expectedResult.single
    }
}
