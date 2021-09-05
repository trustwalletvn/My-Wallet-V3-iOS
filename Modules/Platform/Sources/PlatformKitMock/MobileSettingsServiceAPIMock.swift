// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

class MobileSettingsServiceAPIMock: MobileSettingsServiceAPI {

    var singleValuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        .just(underlyingWalletSettings)
    }

    var valuePublisher: AnyPublisher<WalletSettings, SettingsServiceError> {
        .just(underlyingWalletSettings)
    }

    func fetchPublisher(force: Bool) -> AnyPublisher<WalletSettings, SettingsServiceError> {
        .just(underlyingWalletSettings)
    }

    var underlyingWalletSettings: WalletSettings!

    var valueSingle: Single<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    var valueObservable: Observable<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    func fetch(force: Bool) -> Single<WalletSettings> {
        .just(underlyingWalletSettings)
    }

    func update(mobileNumber: String) -> Completable {
        .empty()
    }

    func verify(with code: String) -> Completable {
        .empty()
    }
}
