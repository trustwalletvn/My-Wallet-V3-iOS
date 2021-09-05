// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RIBs
import RxSwift

// MARK: - Listener Bridge

enum TargetSelectionListenerBridge {
    case simple(AccountPickerDidSelect)
    case listener(TargetSelectionPageListener)
}

// MARK: - Builder

typealias BackButtonInterceptor = () -> Observable<
    (
        step: TransactionFlowStep,
        backStack: [TransactionFlowStep],
        isGoingBack: Bool
    )
>

protocol TargetSelectionBuildable {
    func build(
        listener: TargetSelectionListenerBridge,
        navigationModel: ScreenNavigationModel,
        backButtonInterceptor: @escaping BackButtonInterceptor
    ) -> TargetSelectionPageRouting
}

final class TargetSelectionPageBuilder: TargetSelectionBuildable {

    // MARK: - Private Properties

    private let accountProvider: SourceAndTargetAccountProviding
    private let action: AssetAction

    // MARK: - Init

    init(
        accountProvider: SourceAndTargetAccountProviding,
        action: AssetAction
    ) {
        self.accountProvider = accountProvider
        self.action = action
    }

    // MARK: - Public Methods

    func build(
        listener: TargetSelectionListenerBridge,
        navigationModel: ScreenNavigationModel,
        backButtonInterceptor: @escaping BackButtonInterceptor
    ) -> TargetSelectionPageRouting {
        let shouldOverrideNavigationEffects: Bool
        switch listener {
        case .listener:
            shouldOverrideNavigationEffects = true
        case .simple:
            shouldOverrideNavigationEffects = false
        }
        let viewController = TargetSelectionViewController(
            shouldOverrideNavigationEffects: shouldOverrideNavigationEffects
        )
        let reducer = TargetSelectionPageReducer(action: action, navigationModel: navigationModel)
        let presenter = TargetSelectionPagePresenter(
            viewController: viewController,
            action: action,
            selectionPageReducer: reducer
        )
        let radioSelectionHandler = RadioSelectionHandler()
        let interactor = TargetSelectionPageInteractor(
            targetSelectionPageModel: .init(interactor: TargetSelectionInteractor()),
            presenter: presenter,
            accountProvider: accountProvider,
            listener: listener,
            action: action,
            radioSelectionHandler: radioSelectionHandler,
            backButtonInterceptor: backButtonInterceptor
        )
        return TargetSelectionPageRouter(interactor: interactor, viewController: viewController)
    }
}
