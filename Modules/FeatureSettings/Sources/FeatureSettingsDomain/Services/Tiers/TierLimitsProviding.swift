// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public protocol TierLimitsProviding {
    var tiers: Observable<KYC.UserTiers> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

final class TierLimitsProvider: TierLimitsProviding {

    let fetchTriggerRelay = PublishRelay<Void>()

    private let tiersService: KYCTiersServiceAPI

    var tiers: Observable<KYC.UserTiers> {
        Observable.combineLatest(tiersService.tiers.asObservable(), fetchTriggerRelay).map(\.0)
    }

    init(tiersService: KYCTiersServiceAPI = resolve()) {
        self.tiersService = tiersService
    }
}
