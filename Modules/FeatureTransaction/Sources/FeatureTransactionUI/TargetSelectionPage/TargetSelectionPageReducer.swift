// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

/// Types adopting this should be able to provide a stream of presentable state of type `TargetSelectionPagePresenter.State` which is used by `TargetSelectionPagePresentable` that presents the neccessary sections define in the state.
protocol TargetSelectionPageReducerAPI {
    /// Provides a stream of `TargetSelectionPagePresenter.State` from the given `TargetSelectionPageInteractor.State`
    /// - Parameter interactorState: A stream of `TargetSelectionPageInteractor.State` as defined by `TargetSelectionPageInteractor`
    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State>
}

final class TargetSelectionPageReducer: TargetSelectionPageReducerAPI {

    private typealias LocalizationIds = LocalizationConstants.Transaction.TargetSource
    private let action: AssetAction
    private let navigationModel: ScreenNavigationModel
    private let featureFetcher: FeatureFetching

    init(
        action: AssetAction,
        navigationModel: ScreenNavigationModel,
        featureFetcher: FeatureFetching = resolve()
    ) {
        self.action = action
        self.navigationModel = navigationModel
        self.featureFetcher = featureFetcher
    }

    func presentableState(for interactorState: Driver<TargetSelectionPageInteractor.State>) -> Driver<TargetSelectionPagePresenter.State> {
        let action = self.action
        let sourceSection = interactorState
            .compactMap(\.sourceInteractor)
            .map { [$0] }
            .map { items -> [TargetSelectionPageCellItem] in
                items.map { interactor in
                    TargetSelectionPageCellItem(interactor: interactor, assetAction: action)
                }
            }
            .flatMap { [weak self] items -> Driver<TargetSelectionPageSectionModel> in
                guard let self = self else { return .empty() }
                return .just(.source(header: self.provideSourceSectionHeader(for: action), items: items))
            }

        let sourceAccountStrategy = interactorState
            .compactMap(\.sourceInteractor)
            .map(\.account)
            .map { account -> TargetDestinationsStrategyAPI in
                AnySourceDestinationStrategy(sourceAccount: account)
            }
            .map(TargetDestinationSections.init(strategy:))

        let destinationSections = interactorState
            .map(\.destinationInteractors)
            .withLatestFrom(sourceAccountStrategy) { ($0, $1) }
            .map { items, strategy -> [TargetSelectionPageSectionModel] in
                strategy.sections(interactors: items, action: action)
            }

        let inputFieldSection = interactorState
            .map(\.inputFieldInteractor)
            .distinctUntilChanged()
            .map { item -> [TargetSelectionPageSectionModel] in
                guard let item = item else {
                    return []
                }
                let header = TargetSelectionHeaderBuilder(
                    headerType: .section(.init(sectionTitle: LocalizationConstants.Transaction.to))
                )
                let section = TargetSelectionPageSectionModel.destination(
                    header: header,
                    items: [.init(interactor: item, assetAction: action)]
                )
                return [section]
            }

        let button = interactorState
            .map(\.actionButtonEnabled)
            .map { canContinue -> ButtonViewModel in
                let viewModel: ButtonViewModel = .primary(with: LocalizationConstants.Transaction.next)
                viewModel.isEnabledRelay.accept(canContinue)
                return viewModel
            }
            .asDriver()

        let sections = Driver
            .combineLatest(sourceSection, inputFieldSection, destinationSections)
            .map { [$0] + $1 + $2 }

        let navigationModel = self.navigationModel
        return Driver.combineLatest(sections, button)
            .map { values -> TargetSelectionPagePresenter.State in
                let (sections, button) = values
                return .init(
                    actionButtonModel: button,
                    navigationModel: navigationModel,
                    sections: sections
                )
            }
    }

    // MARK: - Static methods

    private func provideSourceSectionHeader(for action: AssetAction) -> TargetSelectionHeaderBuilder {
        switch action {
        case .swap:
            return TargetSelectionHeaderBuilder(
                headerType: .titledSection(
                    .init(
                        title: LocalizationConstants.Transaction.Swap.newSwapDisclaimer,
                        sectionTitle: LocalizationConstants.Transaction.Swap.swap
                    )
                )
            )
        case .send,
             .withdraw:
            return TargetSelectionHeaderBuilder(
                headerType: .section(
                    .init(
                        sectionTitle: LocalizationConstants.Transaction.from
                    )
                )
            )
        case .deposit,
             .receive,
             .buy,
             .sell,
             .viewActivity:
            unimplemented()
        }
    }
}
