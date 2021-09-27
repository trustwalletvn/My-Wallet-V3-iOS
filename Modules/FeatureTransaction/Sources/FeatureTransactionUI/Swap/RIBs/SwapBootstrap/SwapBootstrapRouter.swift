// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol SwapBootstrapInteractable: Interactable {
    var router: SwapBootstrapRouting? { get set }
    var listener: SwapBootstrapListener? { get set }
}

protocol SwapBootstrapViewControllable: ViewControllable {}

final class SwapBootstrapRouter: ViewableRouter<SwapBootstrapInteractable, SwapBootstrapViewControllable>, SwapBootstrapRouting {
    override init(interactor: SwapBootstrapInteractable, viewController: SwapBootstrapViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
