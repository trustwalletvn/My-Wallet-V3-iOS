// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureAuthenticationDomain
import PlatformKit
import RxSwift

/// Entry Point for any remote notifications network requests and responses
protocol RemoteNotificationNetworkServicing: AnyObject {
    /// Send network request for remote notifications registration
    /// - Parameters:
    ///   - deviceToken: A token string that identifies the device
    ///   - sharedKeyProvider: A data repository that provides shared key
    ///   - guidProvider: A data repository that provides guid
    func register(
        with deviceToken: String,
        sharedKeyProvider: SharedKeyRepositoryAPI,
        guidProvider: GuidRepositoryAPI
    ) -> Single<Void>
}
