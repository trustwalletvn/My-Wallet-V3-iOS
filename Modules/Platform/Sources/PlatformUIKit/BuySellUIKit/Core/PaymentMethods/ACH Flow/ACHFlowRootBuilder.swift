// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

// MARK: - Builder

protocol ACHFlowRootBuildable {
    /// Builds the new payment method flow
    /// - Parameter presentingController: A `NavigationControllerAPI` object that acts as a presenting controller
    func build(presentingController: NavigationControllerAPI?) -> ACHFlowStarter
}

final class ACHFlowRootBuilder: ACHFlowRootBuildable {

    private let stateService: StateServiceAPI

    init(stateService: StateServiceAPI) {
        self.stateService = stateService
    }

    func build(presentingController: NavigationControllerAPI?) -> ACHFlowStarter {
        let paymentMethodService = SelectPaymentMethodService()
        let selectPaymentMethodBuilder = SelectPaymentMethodBuilder(
            paymentMethodService: paymentMethodService
        )
        let addNewPaymentMethodBuilder = AddNewPaymentMethodBuilder(paymentMethodService: paymentMethodService)
        let interactor = ACHFlowRootInteractor(stateService: stateService, paymentMethodService: paymentMethodService)
        let router = ACHFlowRootRouter(
            interactor: interactor,
            navigation: presentingController,
            selectPaymentMethodBuilder: selectPaymentMethodBuilder,
            addNewPaymentMethodBuilder: addNewPaymentMethodBuilder
        )
        return router
    }
}
