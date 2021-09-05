// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

protocol SelectPaymentMethodBuildable {
    func build(listener: SelectPaymentMethodListener) -> SelectPaymentMethodRouting
}

final class SelectPaymentMethodBuilder: SelectPaymentMethodBuildable {

    private let paymentMethodService: SelectPaymentMethodService

    init(paymentMethodService: SelectPaymentMethodService) {
        self.paymentMethodService = paymentMethodService
    }

    func build(listener: SelectPaymentMethodListener) -> SelectPaymentMethodRouting {
        let viewController = SelectPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = SelectPaymentMethodInteractor(
            presenter: viewController,
            paymentMethodService: paymentMethodService
        )
        interactor.listener = listener
        return SelectPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
