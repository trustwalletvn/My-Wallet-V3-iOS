// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import UIKit

protocol BuyFlowRouting: Routing {

    func start(with cryptoAccount: CryptoAccount?, from presenter: UIViewController)
}

final class BuyFlowRouter: RIBs.Router<BuyFlowInteractor>, BuyFlowRouting {

    func start(with cryptoAccount: CryptoAccount?, from presenter: UIViewController) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .buy,
            sourceAccount: nil,
            target: cryptoAccount
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        presenter.present(viewController, animated: true)
    }
}
