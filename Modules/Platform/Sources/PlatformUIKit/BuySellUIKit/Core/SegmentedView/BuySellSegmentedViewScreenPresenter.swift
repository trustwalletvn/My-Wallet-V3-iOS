// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class BuySellSegmentedViewScreenPresenter: SegmentedViewScreenPresenting {

    // MARK: Public Properties

    public let leadingButton: Screen.Style.LeadingButton = .drawer
    public let leadingButtonTapRelay: PublishRelay<Void> = .init()

    public let trailingButton: Screen.Style.TrailingButton = .none
    public let trailingButtonTapRelay: PublishRelay<Void> = .init()

    public let barStyle: Screen.Style.Bar = .lightContent()

    public private(set) lazy var segmentedViewModel: SegmentedViewModel = createSegmentedViewModel()

    public private(set) lazy var items: [SegmentedViewScreenItem] = segmentedItemsFactory.createItems()

    public let itemIndexSelectedRelay: BehaviorRelay<Int?> = .init(value: nil)

    // MARK: Private Properties

    private let drawerRouter: DrawerRouting
    private let segmentedItemsFactory: BuySellSegmentedItemsFactory
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(drawerRouter: DrawerRouting = resolve()) {
        self.drawerRouter = drawerRouter
        segmentedItemsFactory = BuySellSegmentedItemsFactory()

        leadingButtonTapRelay
            .bindAndCatch(weak: self) { (self) in
                self.drawerRouter.toggleSideMenu()
            }
            .disposed(by: disposeBag)
    }
}
