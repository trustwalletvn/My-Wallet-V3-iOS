// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A provider protocol for top most view controller
public protocol TopMostViewControllerProviding: AnyObject {
    var topMostViewController: UIViewController? { get }
}

// MARK: - UIApplication

extension UIApplication: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        keyWindow?.topMostViewController
    }
}

// MARK: - UIWindow

extension UIWindow: TopMostViewControllerProviding {
    public var topMostViewController: UIViewController? {
        rootViewController?.topMostViewController
    }
}

// MARK: - UIViewController

extension UIViewController: TopMostViewControllerProviding {

    /// Returns the top-most visibly presented UIViewController in this UIViewController's hierarchy
    @objc
    public var topMostViewController: UIViewController? {
        switch self {
        case is UIAlertController:
            return presentedViewController?.topMostViewController
        case is UINavigationController:
            return presentedViewController?.topMostViewController ?? self
        default:
            return presentedViewController?.topMostViewController ?? self
        }
    }
}
