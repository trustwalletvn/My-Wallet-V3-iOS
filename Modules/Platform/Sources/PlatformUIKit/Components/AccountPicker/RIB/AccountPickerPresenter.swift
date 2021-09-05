// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RIBs
import RxCocoa
import RxSwift

protocol AccountPickerPresentable: Presentable {

    /// An optional button that is displayed at the bottom of the
    /// account picker screen.
    var button: ButtonViewModel? { get }

    /// Connect the interactor to the presenter. Returns effects from the presentation layer.
    /// - Parameter state: The state of the interactor
    func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects>
}

final class AccountPickerPresenter: Presenter<AccountPickerViewControllable>, AccountPickerPresentable {

    // MARK: - Public Properties

    let button: ButtonViewModel?

    // MARK: - Private Properties

    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let headerModel: AccountPickerHeaderType

    // MARK: - Init

    init(
        viewController: AccountPickerViewControllable,
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        headerModel: AccountPickerHeaderType,
        buttonViewModel: ButtonViewModel? = nil
    ) {
        self.action = action
        button = buttonViewModel
        self.navigationModel = navigationModel
        self.headerModel = headerModel
        super.init(viewController: viewController)
    }

    // MARK: - Methods

    func connect(state: Driver<AccountPickerInteractor.State>) -> Driver<AccountPickerInteractor.Effects> {
        let action = self.action
        let sections = state.map(\.interactors)
            .map { items -> [AccountPickerCellItem] in
                items.map { interactor in
                    AccountPickerCellItem(interactor: interactor, assetAction: action)
                }
            }
            .map { AccountPickerSectionViewModel(items: $0) }
            .map { [$0] }
            .startWith([])

        let headerModel = self.headerModel
        let navigationModel = self.navigationModel
        let presentableState = sections
            .map { sections -> AccountPickerPresenter.State in
                AccountPickerPresenter.State(
                    headerModel: headerModel,
                    navigationModel: navigationModel,
                    sections: sections
                )
            }
        return viewController.connect(state: presentableState)
    }
}

extension AccountPickerPresenter {
    struct State {
        var headerModel: AccountPickerHeaderType
        var navigationModel: ScreenNavigationModel
        var sections: [AccountPickerSectionViewModel]
    }
}
