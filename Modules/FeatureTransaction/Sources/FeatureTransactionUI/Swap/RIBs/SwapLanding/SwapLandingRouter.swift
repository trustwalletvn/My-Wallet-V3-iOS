// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol SwapLandingInteractable: Interactable {
    var router: SwapLandingRouting? { get set }
    var listener: SwapLandingListener? { get set }
}

protocol SwapLandingViewControllable: ViewControllable {}

final class SwapLandingRouter: ViewableRouter<SwapLandingInteractable, SwapLandingViewControllable>, SwapLandingRouting {

    override init(interactor: SwapLandingInteractable, viewController: SwapLandingViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
