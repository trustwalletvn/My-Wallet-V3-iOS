// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol AccountPickerInteractable: Interactable {
    var router: AccountPickerRouting? { get set }
}

final class AccountPickerRouter: ViewableRouter<AccountPickerInteractable, AccountPickerViewControllable>, AccountPickerRouting {

    override init(interactor: AccountPickerInteractable, viewController: AccountPickerViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
