// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import UIKit

extension UIViewController {

    // Adds a child view controller and its view
    public func add(child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }

    // Removes self from parent view controller. Also removes its view from the superview
    public func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

    /// Transitions between two child view controllers by applying a cross-disolve animation
    /// - Parameters:
    ///   - fromChild: The `UIViewController` child to be removed
    ///   - toChild: To `UIViewController` child to be added
    ///   - shouldAnimate: If `true` an animation would occur, otherwise the `toChild` will appear immediatally.
    ///                    Default value is `true`
    public func transition(
        from fromChild: UIViewController,
        to toChild: UIViewController,
        animate shouldAnimate: Bool = true
    ) {
        guard shouldAnimate else {
            add(child: toChild)
            fromChild.remove()
            return
        }

        fromChild.willMove(toParent: nil)
        addChild(toChild)
        view.addSubview(toChild.view)
        toChild.view.alpha = 0.0
        UIView.animate(
            withDuration: 0.2,
            animations: {
                fromChild.view.alpha = 0.0
                toChild.view.alpha = 1.0
            },
            completion: { _ in
                fromChild.view.removeFromSuperview()
                fromChild.removeFromParent()
                toChild.didMove(toParent: self)
            }
        )
    }
}
