// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

class MockAlertViewPresenter: AlertViewPresenterAPI {
    var notifyCalled: Bool = false

    func notify(content: AlertViewContent, in viewController: UIViewController?) {
        notifyCalled = true
    }

    var errorCalled: Bool = false

    func error(in viewController: UIViewController?, message: String?, action: (() -> Void)?) {
        errorCalled = true
    }
}
