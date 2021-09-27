// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs

public protocol WithdrawRootBuildable: Buildable {
    func build(sourceAccount: FiatAccount) -> WithdrawRootRouting
}

public final class WithdrawRootBuilder: WithdrawRootBuildable {

    public init() {}

    public func build(sourceAccount: FiatAccount) -> WithdrawRootRouting {
        let interactor = WithdrawRootInteractor(sourceAccount: sourceAccount)
        let router = WithdrawRootRouter(interactor: interactor)
        interactor.router = router
        return router
    }
}
