// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RIBs

// MARK: - Builder

protocol NetworkFeeSelectionBuildable: Buildable {
    func build(
        withListener listener: NetworkFeeSelectionListener,
        transactionModel: TransactionModel
    ) -> NetworkFeeSelectionRouting
}

final class NetworkFeeSelectionBuilder: NetworkFeeSelectionBuildable {
    func build(
        withListener listener: NetworkFeeSelectionListener,
        transactionModel: TransactionModel
    ) -> NetworkFeeSelectionRouting {
        let viewController = NetworkFeeSelectionViewController()
        let reducer = NetworkFeeSelectionReducer()
        let presenter = NetworkFeeSelectionPresenter(viewController: viewController, feeSelectionPageReducer: reducer)

        let interactor = NetworkFeeSelectionInteractor(presenter: presenter, transactionModel: transactionModel)
        interactor.listener = listener
        return NetworkFeeSelectionRouter(interactor: interactor, viewController: viewController)
    }
}
