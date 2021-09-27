// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import Foundation
import Localization
import PlatformKit
import RxSwift

final class SellPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Swap.Completion

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state.map { state in
            PendingTransactionPageState(
                title: String(
                    format: LocalizationIds.Success.title,
                    state.amount.displayString
                ),
                subtitle: String(
                    format: LocalizationIds.Success.description,
                    state.amount.currency.name
                ),
                compositeViewType: .composite(
                    .init(
                        baseViewType: .templateImage(name: "minus-icon", bundle: .platformUIKit, templateColor: .white),
                        sideViewAttributes: .init(
                            type: .image(.local(name: "v-success-icon", bundle: .platformUIKit)),
                            position: .radiusDistanceFromCenter
                        ),
                        cornerRadiusRatio: 0.5
                    )
                ),
                effect: .close,
                buttonViewModel: .primary(with: LocalizationIds.Success.action)
            )
        }
    }
}
