// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift
import ToolKit

/// `SegmentedTabViewController` should be a `child` of `SegmentedViewController`.
/// The `UITabBar` is hidden. Upon selecting an index of the `UISegmentedControl`
/// we select the appropriate `UIViewController`. Having a `UITabBarController` gives us
/// lifecycle events that are the same as a `UITabBarController` while using the segmented control.
/// This also gives us the option to include custom transitions.
public final class SegmentedTabViewController: UITabBarController {

    // MARK: - Public Properties

    let itemIndexSelectedRelay = PublishRelay<Int?>()

    // MARK: - Private Properties

    private let items: [SegmentedViewScreenItem]
    private let disposeBag = DisposeBag()

    // MARK: - Init

    required init?(coder: NSCoder) { unimplemented() }
    public init(items: [SegmentedViewScreenItem]) {
        self.items = items
        super.init(nibName: nil, bundle: nil)
    }

    // MARK: - Lifecycle

    override public func viewDidLoad() {
        super.viewDidLoad()
        setViewControllers(
            items.map(\.viewController),
            animated: false
        )
        tabBar.isHidden = true
        itemIndexSelectedRelay
            .compactMap { $0 }
            .map(weak: self) { (self, index) -> UIViewController? in
                self.viewControllers?[index]
            }
            .compactMap { $0 }
            .bindAndCatch(weak: self) { (self, viewController) in
                self.setSelectedViewController(viewController, animated: true)
            }
            .disposed(by: disposeBag)
    }

    private func setSelectedViewController(_ viewController: UIViewController, animated: Bool) {
        guard animated else {
            selectedViewController = viewController
            return
        }
        guard let fromView = selectedViewController?.view,
              let toView = viewController.view,
              fromView != toView,
              let controllerIndex = viewControllers?.index(of: viewController)
        else {
            return
        }

        let viewSize = fromView.frame
        let scrollRight = controllerIndex > selectedIndex

        // Avoid UI issues when switching tabs fast
        guard fromView.superview?.subviews.contains(toView) == false else {
            return
        }

        fromView.superview?.addSubview(toView)

        let screenWidth = view.frame.width
        toView.frame = CGRect(
            x: scrollRight ? screenWidth : -screenWidth,
            y: viewSize.origin.y,
            width: screenWidth,
            height: viewSize.size.height
        )

        UIView.animate(
            withDuration: 0.25,
            delay: 0,
            options: [.curveEaseOut, .preferredFramesPerSecond60],
            animations: {
                fromView.frame = CGRect(
                    x: scrollRight ? -screenWidth : screenWidth,
                    y: viewSize.origin.y,
                    width: screenWidth,
                    height: viewSize.size.height
                )
                toView.frame = CGRect(
                    x: 0,
                    y: viewSize.origin.y,
                    width: screenWidth,
                    height: viewSize.size.height
                )
            },
            completion: { [weak self] finished in
                if finished {
                    fromView.removeFromSuperview()
                    self?.selectedIndex = controllerIndex
                }
            }
        )
    }
}
