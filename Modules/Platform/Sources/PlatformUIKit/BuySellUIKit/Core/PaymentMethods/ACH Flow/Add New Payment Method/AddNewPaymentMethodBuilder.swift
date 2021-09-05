// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

public protocol AddNewPaymentMethodBuildable {
    func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting
}

public final class AddNewPaymentMethodBuilder: AddNewPaymentMethodBuildable {

    private let paymentMethodService: SelectPaymentMethodService

    public init(paymentMethodService: SelectPaymentMethodService) {
        self.paymentMethodService = paymentMethodService
    }

    public func build(listener: AddNewPaymentMethodListener) -> AddNewPaymentMethodRouting {
        let viewController = AddNewPaymentMethodViewController()
        viewController.isModalInPresentation = true
        let interactor = AddNewPaymentMethodInteractor(
            presenter: viewController,
            paymentMethodService: paymentMethodService
        )
        interactor.listener = listener
        return AddNewPaymentMethodRouter(interactor: interactor, viewController: viewController)
    }
}
