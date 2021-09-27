// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class TwoFactorVerificationBadgeInteractor: DefaultBadgeAssetInteractor {

    // MARK: - Setup

    init(service: SettingsServiceAPI) {
        super.init()
        service
            .valueObservable
            .map(\.authenticator.isTwoFactor)
            .map { $0 ? .verified : .unverified }
            .map { .loaded(next: $0) }
            // TODO: Error handing
            .catchErrorJustReturn(.loading)
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
