// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

protocol SwapLandingBuildable: Buildable {
    func build(withListener listener: SwapLandingListener) -> SwapLandingRouting
}

final class SwapLandingBuilder: SwapLandingBuildable {

    func build(withListener listener: SwapLandingListener) -> SwapLandingRouting {
        let viewController = SwapLandingViewController()
        let interactor = SwapLandingInteractor(presenter: viewController)
        interactor.listener = listener
        return SwapLandingRouter(interactor: interactor, viewController: viewController)
    }
}
