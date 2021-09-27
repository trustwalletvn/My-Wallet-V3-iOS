// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import ToolKit

protocol PaymentMethodInteractable: Interactable {
    var router: PaymentMethodRouting? { get set }
    var listener: PaymentMethodListener? { get set }
}

protocol PaymentMethodViewControllable: ViewControllable,
    PaymentMethodPresentable
{
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class PaymentMethodRouter: ViewableRouter<PaymentMethodInteractable, PaymentMethodViewControllable>, PaymentMethodRouting {

    override init(interactor: PaymentMethodInteractable, viewController: PaymentMethodViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    // MARK: - PaymentMethodRouting

    func routeToWireTransfer() {
        unimplemented()
    }

    func routeToLinkedBanks() {
        unimplemented()
    }
}
