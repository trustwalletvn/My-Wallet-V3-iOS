// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import RxCocoa

protocol NetworkFeeSelectionInteractable: Interactable {
    var router: NetworkFeeSelectionRouting? { get set }
    var listener: NetworkFeeSelectionListener? { get set }
}

protocol NetworkFeeSelectionViewControllable: ViewControllable {
    func connect(state: Driver<NetworkFeeSelectionPresenter.State>) -> Driver<NetworkFeeSelectionEffects>
}

final class NetworkFeeSelectionRouter: ViewableRouter<
    NetworkFeeSelectionInteractable,
    NetworkFeeSelectionViewControllable
>, NetworkFeeSelectionRouting {

    // TODO: Constructor inject child builder protocols to allow building children.
    override init(interactor: NetworkFeeSelectionInteractable, viewController: NetworkFeeSelectionViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
