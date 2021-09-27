// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RIBs
import ToolKit

protocol LinkedBanksInteractable: Interactable {
    var router: LinkedBanksRouting? { get set }
    var listener: LinkedBanksListener? { get set }
}

protocol LinkedBanksViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class LinkedBanksRouter: ViewableRouter<LinkedBanksInteractable, LinkedBanksViewControllable>, LinkedBanksRouting {

    override init(interactor: LinkedBanksInteractable, viewController: LinkedBanksViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
