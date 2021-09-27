// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol BuyFlowBuildable: Buildable {
    func build(with listener: BuyFlowListening, interactor: BuyFlowInteractor) -> BuyFlowRouting
}

final class BuyFlowBuilder: BuyFlowBuildable {

    func build(with listener: BuyFlowListening, interactor: BuyFlowInteractor) -> BuyFlowRouting {
        let router = BuyFlowRouter(interactor: interactor)
        interactor.listener = listener
        interactor.router = router
        return router
    }
}
