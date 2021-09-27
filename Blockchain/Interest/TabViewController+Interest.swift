// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureInterestUI

extension TabViewController {
    func showInterestIdentityVerificationScreen(_ controller: InterestDashboardAnnouncementViewController) {
        controller.transitioningDelegate = sheetPresenter
        controller.modalPresentationStyle = .custom
        controller.isModalInPresentation = true
        present(controller, animated: true, completion: nil)
    }
}
