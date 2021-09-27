// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import RIBs
import RxCocoa

protocol TargetSelectionPagePresentable: Presentable {
    func connect(state: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPageInteractor.Effects>
}

final class TargetSelectionPagePresenter: Presenter<TargetSelectionPageViewControllable>, TargetSelectionPagePresentable {

    // MARK: - Private Properties

    private let action: AssetAction
    private let selectionPageReducer: TargetSelectionPageReducerAPI

    // MARK: - Init

    init(
        viewController: TargetSelectionPageViewControllable,
        action: AssetAction,
        selectionPageReducer: TargetSelectionPageReducerAPI
    ) {
        self.action = action
        self.selectionPageReducer = selectionPageReducer
        super.init(viewController: viewController)
    }

    // MARK: - Methods

    func connect(state: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPageInteractor.Effects> {
        let presentableState = selectionPageReducer.presentableState(for: state)
        return viewController.connect(state: presentableState)
    }
}

extension TargetSelectionPagePresenter {
    struct State {
        var actionButtonModel: ButtonViewModel
        var navigationModel: ScreenNavigationModel
        var sections: [TargetSelectionPageSectionModel]
    }
}
