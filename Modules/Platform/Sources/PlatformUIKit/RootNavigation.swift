// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RIBs
import UIKit

public protocol RootNavigatable: ViewControllable {
    /// Sets the passed `ViewControllable` as the root controller
    /// - note
    ///     This uses the `setViewControllers` of UINavigationController to alter the hierarchy
    ///     of the stack any controllers that are in the stack will be replaced by the passed controller.
    /// - parameter controller: An object conforming to `ViewControllable` protocol
    func set(root controller: ViewControllable)

    /// Pushes the passed `ViewControllable` as the root controller
    /// - parameter controller: An object conforming to `ViewControllable` protocol
    /// - parameter animated: Set to `true` if you want to animate the transition or `false` if you don't want to animate.
    func push(controller: ViewControllable, animated: Bool)

    /// Pushes the passed `ViewControllable` as the root controller using a default animated transitions
    /// - parameter controller: An object conforming to `ViewControllable` protocol
    func push(controller: ViewControllable)

    /// Removes the top `UIViewController` from the navigation stack
    /// - parameter animated: Set to `true` if you want to animate the transition or `false` if you don't want to animate.
    func popController(animated: Bool)

    /// Removes the top `UIViewController` from the navigation stack
    func popController()

    /// Dismisses the view controller that was presented modally by the view controller.
    /// - parameter animated: Pass true to animate the transition.
    /// - parameter completion: An optional block to execute after the view controller is dismissed.
    func dismissController(animated: Bool, completion: (() -> Void)?)

    /// Dismisses the view controller that was presented modally by the view controller.
    /// - parameter animated: Pass true to animate the transition.
    func dismissController(animated: Bool)
}

/// A subclass of UINavigationController conforming to `RootNavigatable`
open class RootNavigation: UINavigationController, RootNavigatable {

    public func push(controller: ViewControllable, animated: Bool) {
        pushViewController(controller.uiviewController, animated: animated)
    }

    public func push(controller: ViewControllable) {
        push(controller: controller, animated: true)
    }

    public func set(root controller: ViewControllable) {
        setViewControllers([controller.uiviewController], animated: false)
    }

    public func popController() {
        popController(animated: true)
    }

    public func popController(animated: Bool) {
        popViewController(animated: animated)
    }

    public func dismissController(animated: Bool, completion: (() -> Void)?) {
        dismiss(animated: animated, completion: completion)
    }

    public func dismissController(animated: Bool) {
        dismiss(animated: true, completion: nil)
    }
}
