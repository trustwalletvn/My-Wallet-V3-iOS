// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift

final class PITConnectionBadgeInteractor: DefaultBadgeAssetInteractor {

    init(provider: PITConnectionStatusProviding) {
        super.init()
        provider
            .hasLinkedPITAccount
            .map { $0 == true ? .connected : .connect }
            .map { .loaded(next: $0) }
            .catchErrorJustReturn(.loading)
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)
    }
}
