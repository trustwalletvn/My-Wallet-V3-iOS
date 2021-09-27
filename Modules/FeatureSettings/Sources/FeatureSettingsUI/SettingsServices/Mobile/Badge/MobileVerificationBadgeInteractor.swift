// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class MobileVerificationBadgeInteractor: DefaultBadgeAssetInteractor {

    init(service: SettingsServiceAPI) {
        super.init()
        service
            .valueObservable
            .map(\.isSMSVerified)
            .map { $0 ? .verified : .unverified }
            .map { .loaded(next: $0) }
            // TODO: Error handing
            .catchErrorJustReturn(.loading)
            .startWith(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
