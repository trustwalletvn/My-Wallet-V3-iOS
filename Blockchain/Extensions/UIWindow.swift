// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ToolKit

extension UIWindow {

    /// Ensure code is running on main thread and sets the rootViewController
    func setRootViewController(_ viewController: UIViewController) {
        ensureIsOnMainQueue()
        rootViewController = viewController
    }
}

#if INTERNAL_BUILD
/// Needed as we're capturing the shake motion on a window level
// swiftlint:disable all
extension UIWindow {
    override open var canBecomeFirstResponder: Bool {
        true
    }

    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        super.motionEnded(motion, with: event)
    }
}
// swiftlint:enable all
#endif
