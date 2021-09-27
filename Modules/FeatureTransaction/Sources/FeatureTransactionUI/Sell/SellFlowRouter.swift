// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift
import ToolKit

protocol SellFlowRouting: Routing {
    func start(with currency: CryptoAccount?, from presenter: UIViewController)
}

final class SellFlowRouter: RIBs.Router<SellFlowInteractor>, SellFlowRouting {

    private let alertPresenter: AlertViewPresenterAPI
    private let loadingViewPresenter: LoadingViewPresenting
    private var cancellables = Set<AnyCancellable>()

    init(
        interactor: SellFlowInteractor,
        alertPresenter: AlertViewPresenterAPI = resolve(),
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        super.init(interactor: interactor)
    }

    func start(with currency: CryptoAccount?, from presenter: UIViewController) {
        let builder = TransactionFlowBuilder()
        let router = builder.build(
            withListener: interactor,
            action: .sell,
            sourceAccount: currency,
            target: nil
        )
        attachChild(router)
        let viewController = router.viewControllable.uiviewController
        presenter.present(viewController, animated: true)
    }

    private func dismissLoadingView() {
        loadingViewPresenter.hide()
    }

    private func presentLoadingView() {
        loadingViewPresenter.showCircular()
    }

    private func presentError(error: Error, from presenter: UIViewController) {
        alertPresenter.notify(
            content: .init(
                title: LocalizationConstants.Errors.genericError,
                message: String(describing: error)
            ),
            in: presenter
        )
    }
}
