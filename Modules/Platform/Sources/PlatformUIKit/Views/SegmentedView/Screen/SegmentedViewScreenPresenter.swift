// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public struct SegmentedViewScreenItem {
    let title: String
    let viewController: UIViewController

    public init(title: String, viewController: UIViewController) {
        self.title = title
        self.viewController = viewController
    }
}

public enum SegmentedViewScreenLocation {
    /// SegmentedView will be on top of view, and the given `Screen.Style.TitleView` will be set to the navigation bar.
    case top(Screen.Style.TitleView)
    /// SegmentedView will be on navigation bar.
    case navBar
}

public protocol SegmentedViewScreenPresenting: AnyObject {

    // MARK: - Navigation Properties

    var leadingButton: Screen.Style.LeadingButton { get }
    var leadingButtonTapRelay: PublishRelay<Void> { get }

    var trailingButton: Screen.Style.TrailingButton { get }
    var trailingButtonTapRelay: PublishRelay<Void> { get }

    var barStyle: Screen.Style.Bar { get }
    var segmentedViewLocation: SegmentedViewScreenLocation { get }

    // MARK: - Segmented View

    var segmentedViewModel: SegmentedViewModel { get }
    var items: [SegmentedViewScreenItem] { get }

    // MARK: - Segmented View Selection

    var itemIndexSelected: Observable<Int?> { get }
    var itemIndexSelectedRelay: BehaviorRelay<Int?> { get }
}

extension SegmentedViewScreenPresenting {
    public func createSegmentedViewModelItems() -> [SegmentedViewModel.Item] {
        items
            .map(\.title)
            .enumerated()
            .map { index, title in
                SegmentedViewModel.Item(
                    content: .title(title),
                    action: { [weak self] in
                        self?.itemIndexSelectedRelay.accept(index)
                    }
                )
            }
    }

    public var itemIndexSelected: Observable<Int?> {
        itemIndexSelectedRelay
            .asObservable()
    }
}
