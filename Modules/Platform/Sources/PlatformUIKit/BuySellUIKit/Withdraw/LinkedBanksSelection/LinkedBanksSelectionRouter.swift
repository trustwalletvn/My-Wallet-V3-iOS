// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs

protocol LinkedBanksSelectionInteractable: Interactable, AddNewBankAccountListener {
    var router: LinkedBanksSelectionRouting? { get set }
    var listener: LinkedBanksSelectionListener? { get set }
}

protocol LinkedBanksSelectionViewControllable: ViewControllable {}

final class LinkedBanksSelectionRouter: ViewableRouter<LinkedBanksSelectionInteractable, LinkedBanksSelectionViewControllable>,
    LinkedBanksSelectionRouting
{

    private let addNewBankBuilder: AddNewBankAccountBuildable

    init(
        interactor: LinkedBanksSelectionInteractable,
        viewController: LinkedBanksSelectionViewControllable,
        addNewBankBuilder: AddNewBankAccountBuildable
    ) {
        self.addNewBankBuilder = addNewBankBuilder
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }

    override func didLoad() {
        super.didLoad()
    }

    func addNewBank() {
        let router = addNewBankBuilder.build(listener: interactor)
        attachChild(router)
        let navigationController = UINavigationController(rootViewController: router.viewControllable.uiviewController)
        viewController.uiviewController.present(navigationController, animated: true, completion: nil)
    }

    func dismissAddNewBank() {
        detachCurrentChild()
        viewController.uiviewController.dismiss(animated: true, completion: nil)
    }

    // MARK: - Private methods

    func detachCurrentChild() {
        guard let currentRouter = children.last else {
            return
        }
        detachChild(currentRouter)
    }
}
