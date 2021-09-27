// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import SwiftUI

final class TargetAuxiliaryViewPresenter: AuxiliaryViewPresenting {

    private let interactor: TargetAuxiliaryViewInteractor
    private let transactionState: TransactionState

    init(interactor: TargetAuxiliaryViewInteractor, transactionState: TransactionState) {
        self.interactor = interactor
        self.transactionState = transactionState
    }

    func makeViewController() -> UIViewController {
        guard let account = transactionState.destination as? CryptoAccount else {
            fatalError("Impossible: a buy can only have a crypto destination and needs to have a fiat rate!")
        }

        guard let conversionRate = transactionState.sourceToFiatPair else {
            return UIHostingController(
                rootView: TargetAccountAuxiliaryView(
                    asset: account.asset,
                    price: .zero(currency: account.asset.currency),
                    action: { [interactor, transactionState] in
                        interactor.handleTopAuxiliaryViewTapped(state: transactionState)
                    }
                )
                .redacted(reason: .placeholder)
            )
        }

        return UIHostingController(
            rootView: TargetAccountAuxiliaryView(
                asset: account.asset,
                price: conversionRate.quote,
                action: { [interactor, transactionState] in
                    interactor.handleTopAuxiliaryViewTapped(state: transactionState)
                }
            )
        )
    }
}
