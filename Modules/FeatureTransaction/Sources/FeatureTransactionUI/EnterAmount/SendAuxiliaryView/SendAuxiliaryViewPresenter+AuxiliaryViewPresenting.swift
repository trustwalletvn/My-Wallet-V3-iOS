// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

extension SendAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    func makeViewController() -> UIViewController {
        let view = SendAuxiliaryView()
        view.presenter = self
        let viewController = UIViewController()
        viewController.view.addSubview(view)
        view.constraint(edgesTo: viewController.view)
        return viewController
    }
}
