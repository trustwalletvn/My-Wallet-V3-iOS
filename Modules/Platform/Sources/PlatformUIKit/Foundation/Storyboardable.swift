// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public protocol Storyboardable: AnyObject {
    static var defaultStoryboardName: String { get }
}

extension Storyboardable where Self: UIViewController {
    public static var defaultStoryboardName: String {
        String(describing: self)
    }

    public static func makeFromStoryboard(in bundle: Bundle = Bundle(for: Self.self)) -> Self {
        let storyboard = UIStoryboard(name: defaultStoryboardName, bundle: bundle)

        guard let viewController = storyboard.instantiateInitialViewController() as? Self else {
            fatalError("Could not instantiate initial storyboard with name: \(defaultStoryboardName)")
        }

        return viewController
    }
}

extension UIViewController: Storyboardable {}
