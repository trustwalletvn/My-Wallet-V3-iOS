// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCUI
import PlatformUIKit

extension KYCTiersViewController: NavigatableView {

    var leftCTATintColor: UIColor {
        .white
    }

    var rightCTATintColor: UIColor {
        .white
    }

    var leftNavControllerCTAType: NavigationCTAType {
        guard let navController = navigationController else { return .dismiss }
        return navController.viewControllers.count > 1 ? .back : .dismiss
    }

    var rightNavControllerCTAType: NavigationCTAType {
        .none
    }

    var barStyle: Screen.Style.Bar {
        .lightContent()
    }

    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        guard let navController = navigationController else {
            dismiss(animated: true, completion: nil)
            return
        }
        navController.popViewController(animated: true)
    }

    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // no op
    }
}
