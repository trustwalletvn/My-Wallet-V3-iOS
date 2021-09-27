// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

final class DashboardFiatBalancesInteractor {

    var shouldAppear: Observable<Bool> {
        fiatBalancesInteractor.hasBalances
    }

    let fiatBalancesInteractor: FiatBalancesInteracting

    // MARK: - Setup

    init(fiatBalancesInteractor: FiatBalancesInteracting) {
        self.fiatBalancesInteractor = fiatBalancesInteractor
    }

    func refresh() {
        fiatBalancesInteractor.reloadBalances()
    }
}
