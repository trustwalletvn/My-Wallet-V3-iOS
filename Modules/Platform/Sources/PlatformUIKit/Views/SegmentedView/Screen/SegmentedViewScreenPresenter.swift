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

public protocol SegmentedViewScreenPresenting: AnyObject {

    // MARK: - Navigation Properties

    var leadingButton: Screen.Style.LeadingButton { get }
    var leadingButtonTapRelay: PublishRelay<Void> { get }

    var trailingButton: Screen.Style.TrailingButton { get }
    var trailingButtonTapRelay: PublishRelay<Void> { get }

    var barStyle: Screen.Style.Bar { get }

    // MARK: - Segmented View

    var segmentedViewModel: SegmentedViewModel { get }
    var items: [SegmentedViewScreenItem] { get }

    // MARK: - Segmented View Selection

    var itemIndexSelected: Observable<Int?> { get }
    var itemIndexSelectedRelay: BehaviorRelay<Int?> { get }
}

extension SegmentedViewScreenPresenting {
    public func createSegmentedViewModel() -> SegmentedViewModel {
        let items: [SegmentedViewModel.Item] = self.items
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
        return SegmentedViewModel.default(
            items: items,
            isMomentary: false,
            defaultSelectedSegmentIndex: 0
        )
    }

    public var itemIndexSelected: Observable<Int?> {
        itemIndexSelectedRelay
            .asObservable()
    }
}
