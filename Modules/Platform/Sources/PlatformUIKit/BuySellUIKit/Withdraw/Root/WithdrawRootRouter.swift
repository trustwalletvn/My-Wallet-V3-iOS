// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import RxCocoa

protocol WithdrawFlowInteractable: Interactable,
    LinkedBanksSelectionListener,
    WithdrawAmountPageListener,
    CheckoutPageListener
{
    var router: WithdrawFlowRouting? { get set }
    var listener: WithdrawFlowListener? { get set }
}

final class WithdrawRootRouter: RIBs.Router<WithdrawFlowInteractable>,
    WithdrawFlowRouting,
    WithdrawFlowStarter
{

    private let selectBanksBuilder: LinkedBanksSelectionBuildable
    private let enterAmountBuilder: WithdrawAmountPageBuildable
    private let checkoutPageBuilder: CheckoutPageBuildable
    private let navigation: RootNavigatable

    private var dismissFlow: (() -> Void)?

    init(
        interactor: WithdrawFlowInteractable,
        navigation: RootNavigatable,
        selectBanksBuilder: LinkedBanksSelectionBuildable,
        enterAmountBuilder: WithdrawAmountPageBuildable,
        checkoutPageBuilder: CheckoutPageBuildable
    ) {
        self.navigation = navigation
        self.selectBanksBuilder = selectBanksBuilder
        self.enterAmountBuilder = enterAmountBuilder
        self.checkoutPageBuilder = checkoutPageBuilder
        super.init(interactor: interactor)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
    }

    func routeToFlowRoot() {
        let router = selectBanksBuilder.build(listener: interactor)
        attachChild(router)
        navigation.set(root: router.viewControllable)
    }

    func routeToBankSelected(beneficiary: Beneficiary) {
        let router = enterAmountBuilder.build(listener: interactor, beneficiary: beneficiary)
        attachChild(router)
        navigation.push(controller: router.viewControllable)
    }

    func routeToCheckout(checkoutData: WithdrawalCheckoutData) {
        let router = checkoutPageBuilder.build(listener: interactor, checkoutData: checkoutData)
        attachChild(router)
        navigation.push(controller: router.viewControllable)
    }

    func didTapBack() {
        navigation.popController()
        detachCurrentChild()
    }

    func closeFlow() {
        navigation.dismissController(animated: true, completion: dismissFlow)
    }

    // MARK: - WithdrawFlowStarter

    func startFlow(flowDismissed: @escaping () -> Void) {
        dismissFlow = flowDismissed
        interactable.activate()
        load()
    }

    // MARK: - Private methods

    func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }
}
