// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit

enum NavigationCTAType {
    case qrCode
    case dismiss
    case back
    case menu
    case help
    case error
    case activityIndicator
    case none
}

extension NavigationCTAType {
    fileprivate var image: UIImage? {
        switch self {
        case .qrCode:
            return #imageLiteral(resourceName: "qr-code-icon").withRenderingMode(.alwaysTemplate)
        case .dismiss:
            return #imageLiteral(resourceName: "close").withRenderingMode(.alwaysTemplate)
        case .menu:
            return #imageLiteral(resourceName: "drawer-icon").withRenderingMode(.alwaysTemplate)
        case .help:
            return #imageLiteral(resourceName: "icon_menu").withRenderingMode(.alwaysTemplate)
        case .back:
            return #imageLiteral(resourceName: "back_chevron_icon").withRenderingMode(.alwaysTemplate)
        case .error:
            return #imageLiteral(resourceName: "error-triangle.pdf")
        case .activityIndicator:
            return nil
        case .none:
            return nil
        }
    }
}

extension NavigationCTAType {
    var accessibilityIdentifier: String {
        switch self {
        case .qrCode:
            return AccessibilityIdentifiers.Navigation.Button.qrCode
        case .dismiss:
            return AccessibilityIdentifiers.Navigation.Button.dismiss
        case .menu:
            return AccessibilityIdentifiers.Navigation.Button.menu
        case .help:
            return AccessibilityIdentifiers.Navigation.Button.help
        case .back:
            return AccessibilityIdentifiers.Navigation.Button.back
        case .error:
            return AccessibilityIdentifiers.Navigation.Button.error
        case .activityIndicator:
            return AccessibilityIdentifiers.Navigation.Button.activityIndicator
        case .none:
            return ""
        }
    }
}

protocol NavigatableView: AnyObject {

    var rightCTATintColor: UIColor { get }
    var leftCTATintColor: UIColor { get }

    var barStyle: Screen.Style.Bar { get }

    var rightNavControllerCTAType: NavigationCTAType { get }
    var leftNavControllerCTAType: NavigationCTAType { get }

    func navControllerRightBarButtonTapped(_ navController: UINavigationController)
    func navControllerLeftBarButtonTapped(_ navController: UINavigationController)
}

extension NavigatableView where Self: UIViewController {
    var leftCTATintColor: UIColor {
        .white
    }

    var rightCTATintColor: UIColor {
        .white
    }

    var leftNavControllerCTAType: NavigationCTAType {
        .menu
    }

    var rightNavControllerCTAType: NavigationCTAType {
        .qrCode
    }

    var barStyle: Screen.Style.Bar {
        .lightContent()
    }

    func navControllerRightBarButtonTapped(_ navController: UINavigationController) {
        // no-op
    }

    func navControllerLeftBarButtonTapped(_ navController: UINavigationController) {
        navigationController?.popViewController(animated: true)
    }
}

/// It relies on `NavigatableView` to properly layout it's `UIBarButtonItems` as well
/// as style itself. There is no default behavior should the current `UIViewController`
/// not conform to `NavigatableView`. This is because the behaviors across all our different
/// screens are pretty different.
@objc class BaseNavigationController: UINavigationController {

    private var leftBarButtonItem: UIBarButtonItem!
    private var rightBarButtonItem: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        // TODO: This is not efficient as `viewWillLayoutSubviews` can get called unexpectedly on on view changes
        setupNavigationController()
    }

    fileprivate func setupNavigationController() {
        guard let controller = viewControllers.last else { return }
        guard let navigatableView = controller as? NavigatableView else {
            return
        }

        if navigatableView.rightNavControllerCTAType == .activityIndicator {
            let activityIndicator = UIActivityIndicatorView(style: .medium)
            activityIndicator.startAnimating()
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        } else {
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
                image: navigatableView.rightNavControllerCTAType.image,
                style: .plain,
                target: self,
                action: #selector(rightBarButtonTapped)
            )
        }
        controller.navigationItem.rightBarButtonItem?.accessibility = .id(
            navigatableView.rightNavControllerCTAType.accessibilityIdentifier
        )

        if navigatableView.leftNavControllerCTAType == .activityIndicator {
            assertionFailure("You should put the activity indicator in the right CTA.")
        } else {
            controller.navigationItem.leftBarButtonItem = UIBarButtonItem(
                image: navigatableView.leftNavControllerCTAType.image,
                style: .plain,
                target: self,
                action: #selector(leftBarButtonTapped)
            )
            controller.navigationItem.leftBarButtonItem?.accessibility = .id(
                navigatableView.leftNavControllerCTAType.accessibilityIdentifier
            )
        }

        controller.navigationItem.rightBarButtonItem?.tintColor = navigatableView.rightCTATintColor
        controller.navigationItem.leftBarButtonItem?.tintColor = navigatableView.leftCTATintColor
        navigationBar.barTintColor = navigatableView.barStyle.backgroundColor
        navigationBar.titleTextAttributes = navigatableView.barStyle.titleTextAttributes
    }

    @objc func update() {
        setupNavigationController()
    }

    @objc fileprivate func rightBarButtonTapped() {
        guard let navigatableView = visibleViewController as? NavigatableView else {
            return
        }
        guard navigatableView.rightNavControllerCTAType != .activityIndicator else { return }
        navigatableView.navControllerRightBarButtonTapped(self)
    }

    @objc fileprivate func leftBarButtonTapped() {
        guard let navigatableView = visibleViewController as? NavigatableView else {
            return
        }
        navigatableView.navControllerLeftBarButtonTapped(self)
    }
}
