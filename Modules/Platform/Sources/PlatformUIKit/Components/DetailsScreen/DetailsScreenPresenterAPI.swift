// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

public protocol HeaderBuilder {
    var defaultHeight: CGFloat { get }

    func view(fittingWidth width: CGFloat, customHeight: CGFloat?) -> UIView?
}

public protocol DetailsScreenPresenterAPI: AnyObject {

    var buttons: [ButtonViewModel] { get }
    var cells: [DetailsScreen.CellType] { get }

    var extendSafeAreaUnderNavigationBar: Bool { get }
    var titleView: Driver<Screen.Style.TitleView> { get }
    var titleViewRelay: BehaviorRelay<Screen.Style.TitleView> { get }
    var navigationBarAppearance: DetailsScreen.NavigationBarAppearance { get }
    var navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction { get }
    var navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction { get }

    var reloadRelay: PublishRelay<Void> { get }
    var reload: Signal<Void> { get }

    func viewDidLoad()
    func header(for section: Int) -> HeaderBuilder?
}

extension DetailsScreenPresenterAPI {

    public var extendSafeAreaUnderNavigationBar: Bool { false }

    public var buttons: [ButtonViewModel] { [] }

    public var titleView: Driver<Screen.Style.TitleView> {
        titleViewRelay.asDriver()
    }

    public var reload: Signal<Void> {
        reloadRelay.asSignal()
    }

    public func viewDidLoad() { /* NOOP */ }

    public func header(for section: Int) -> HeaderBuilder? { nil }
}
