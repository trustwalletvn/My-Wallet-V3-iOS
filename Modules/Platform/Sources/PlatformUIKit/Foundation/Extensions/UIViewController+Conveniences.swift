// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension UIViewController {
    public var isPresentedModally: Bool {
        let isModal = presentingViewController != nil
        let isNavigationControllerModal = navigationController?.presentingViewController != nil
        let isTabBarModel = tabBarController?.presentingViewController != nil
        return isModal || isNavigationControllerModal || isTabBarModel
    }
}
