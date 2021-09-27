// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

protocol PaymentMethodBuildable: Buildable {
    func build(withListener listener: PaymentMethodListener) -> PaymentMethodRouting
}

final class PaymentMethodBuilder: PaymentMethodBuildable {

    // TODO: Consider injecting an `AssetAction` as the action may dictate
    // what payment methods are available to the user.
    init() {}

    func build(withListener listener: PaymentMethodListener) -> PaymentMethodRouting {
        let viewController = PaymentMethodViewController()
        let interactor = PaymentMethodInteractor(presenter: viewController)
        interactor.listener = listener
        let router = PaymentMethodRouter(interactor: interactor, viewController: viewController)
        interactor.router = router
        return router
    }
}
