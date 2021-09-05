// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class AccountGroupBalanceCellInteractor {

    let balanceViewInteractor: WalletBalanceViewInteractor

    init(balanceViewInteractor: WalletBalanceViewInteractor) {
        self.balanceViewInteractor = balanceViewInteractor
    }
}
