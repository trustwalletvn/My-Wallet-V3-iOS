// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RIBs
import RxCocoa

final class NetworkFeeSelectionPresenter: Presenter<NetworkFeeSelectionViewControllable>, NetworkFeeSelectionPresentable {

    weak var listener: NetworkFeeSelectionPresentableListener?

    struct State {
        var title: LabelContent
        var isOkEnabled: Driver<Bool>
        var regular: RadioLineItemCellPresenter
        var priority: RadioLineItemCellPresenter

        var sections: [NetworkFeeSelectionSectionModel] {
            let section = NetworkFeeSelectionSectionModel(
                items: [
                    .label(title),
                    .separator(0),
                    .radio(regular),
                    .separator(1),
                    .radio(priority)
                ]
            )
            return [section]
        }
    }

    // MARK: - Private Properties

    private let feeSelectionPageReducer: NetworkFeeSelectionReducerAPI

    // MARK: - Init

    init(
        viewController: NetworkFeeSelectionViewControllable,
        feeSelectionPageReducer: NetworkFeeSelectionReducerAPI
    ) {
        self.feeSelectionPageReducer = feeSelectionPageReducer
        super.init(viewController: viewController)
    }

    func connect(state: Driver<NetworkFeeSelectionInteractor.State>) -> Driver<NetworkFeeSelectionEffects> {
        let presentableState = feeSelectionPageReducer.presentableState(for: state)
        return viewController.connect(state: presentableState)
    }
}
