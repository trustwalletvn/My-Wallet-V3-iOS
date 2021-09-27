// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs

// MARK: - Builder

public protocol DepositRootBuildable: Buildable {
    func build(with account: FiatAccount) -> DepositRootRouting
}

public final class DepositRootBuilder: DepositRootBuildable {

    public init() {}

    public func build(with account: FiatAccount) -> DepositRootRouting {
        let interactor = DepositRootInteractor(targetAccount: account)
        let router = DepositRootRouter(interactor: interactor)
        interactor.router = router
        return router
    }
}
