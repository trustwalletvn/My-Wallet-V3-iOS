// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

public protocol SendRootBuildable: Buildable {
    func build() -> SendRootRouting
}

public final class SendRootBuilder: SendRootBuildable {

    public init() {}

    public func build() -> SendRootRouting {
        let viewController = SendRootViewController()
        let interactor = SendRootInteractor()
        viewController.listener = interactor
        let router = SendRootRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        return router
    }
}
