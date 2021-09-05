// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import UIKit

protocol CheckoutPageBuildable {
    func build(listener: CheckoutPageListener, checkoutData: WithdrawalCheckoutData) -> CheckoutPageRouter
}

final class CheckoutPageBuilder: CheckoutPageBuildable {
    func build(listener: CheckoutPageListener, checkoutData: WithdrawalCheckoutData) -> CheckoutPageRouter {
        let detailsPresenter = CheckoutPageDetailsPresenter(fiatCurrency: checkoutData.currency)
        let checkoutViewController = DetailsScreenViewController(presenter: detailsPresenter)
        let interactor = CheckoutPageInteractor(
            presenter: detailsPresenter,
            checkoutData: checkoutData
        )
        interactor.listener = listener
        let confirmationPageBuilder = ConfirmationPageBuilder()
        let contentPage = ContentPage(state: .render(checkoutViewController))
        return CheckoutPageRouter(
            interactor: interactor,
            contentControllable: contentPage,
            confirmationBuilder: confirmationPageBuilder
        )
    }
}
