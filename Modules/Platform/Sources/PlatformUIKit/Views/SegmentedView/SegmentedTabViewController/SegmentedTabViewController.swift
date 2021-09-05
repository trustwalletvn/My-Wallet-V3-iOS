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
        setViewControllers(
            items.map(\.viewController),
            animated: true
        )
        tabBar.isHidden = true

        itemIndexSelectedRelay
            .compactMap { $0 }
            .map(weak: self) { (self, index) -> UIViewController? in
                self.viewControllers?[index]
            }
            .compactMap { $0 }
            .bindAndCatch(weak: self) { (self, viewController) in
                self.selectedViewController = viewController
            }
            .disposed(by: disposeBag)
    }
}
