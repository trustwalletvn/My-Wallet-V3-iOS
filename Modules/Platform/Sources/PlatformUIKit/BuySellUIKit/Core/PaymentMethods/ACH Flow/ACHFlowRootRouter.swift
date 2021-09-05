// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol ACHFlowRootInteractable: Interactable, SelectPaymentMethodListener, AddNewPaymentMethodListener {
    var router: ACHFlowRootRouting? { get set }
    var listener: ACHFlowRootListener? { get set }
}

public protocol ACHFlowStarter: AnyObject {
    /// Helper method for starting the withdraw flow
    func startFlow(flowDismissed: @escaping () -> Void)
}

protocol ACHFlowRootViewControllable: ViewControllable {
    // Declare methods the router invokes to manipulate the view hierarchy. Since
    // this RIB does not own its own view, this protocol is conformed to by one of this
    // RIB's ancestor RIBs' view.
}

final class ACHFlowRootRouter: RIBs.Router<ACHFlowRootInteractable>,
    ACHFlowRootRouting,
    ACHFlowStarter
{

    private let navigationController: RootNavigatable
    private let navigation: NavigationControllerAPI?
    private let selectPaymentMethodBuilder: SelectPaymentMethodBuildable
    private let addNewPaymentMethodBuilder: AddNewPaymentMethodBuildable

    private var dismissFlow: (() -> Void)?

    init(
        interactor: ACHFlowRootInteractable,
        navigation: NavigationControllerAPI?,
        selectPaymentMethodBuilder: SelectPaymentMethodBuildable,
        addNewPaymentMethodBuilder: AddNewPaymentMethodBuildable
    ) {
        self.navigation = navigation
        self.selectPaymentMethodBuilder = selectPaymentMethodBuilder
        self.addNewPaymentMethodBuilder = addNewPaymentMethodBuilder
        navigationController = RootNavigation()
        super.init(interactor: interactor)
        interactor.router = self
    }

    // MARK: - ACHFlowRootRouting

    func route(to screen: ACHFlow.Screen) {
        switch screen {
        case .selectMethod:
            let router = selectPaymentMethodBuilder.build(listener: interactor)
            attachChild(router)
            let navController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
            navigation?.present(navController, animated: true, completion: nil)
        case .addPaymentMethod(let initialScreen):
            let router = addNewPaymentMethodBuilder.build(listener: interactor)
            attachChild(router)
            let navController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
            if initialScreen {
                navigation?.present(navController, animated: true, completion: nil)
            } else {
                navigation?.dismiss(animated: true, completion: { [navigation] in
                    navigation?.present(navController, animated: true, completion: nil)
                })
            }
        }
    }

    func closeFlow() {
        dismissFlow?()
    }

    // MARK: - ACHFlowStarter

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
