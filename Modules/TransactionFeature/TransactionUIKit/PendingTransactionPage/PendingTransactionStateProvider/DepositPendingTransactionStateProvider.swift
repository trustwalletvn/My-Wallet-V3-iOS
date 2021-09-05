// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit
import RxCocoa
import RxSwift
import ToolKit

final class DepositPendingTransactionStateProvider: PendingTransactionStateProviding {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Deposit.Completion

    // MARK: - PendingTransactionStateProviding

    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState> {
        state
            .map(weak: self) { (self, state) in
                switch state.executionStatus {
                case .notStarted,
                     .inProgress:
                    return self.pending(state: state)
                case .error:
                    return self.failed(state: state)
                case .completed:
                    return self.success(state: state)
                }
            }
    }

    // MARK: - Private Functions

    private func success(state: TransactionState) -> PendingTransactionPageState {
        let date = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        let value = DateFormatter.medium.string(from: date)
        let amount = state.amount
        let currency = amount.currency
        return .init(
            title: String(format: LocalizationIds.Success.title, amount.displayString),
            subtitle: String(
                format: LocalizationIds.Success.description,
                amount.displayString,
                amount.currencyCode,
                value
            ),
            compositeViewType: .composite(
                .init(
                    baseViewType: .badgeImageViewModel(
                        .primary(
                            image: currency.logoResource,
                            contentColor: .white,
                            backgroundColor: currency.isFiatCurrency ? .fiat : currency.brandColor,
                            cornerRadius: .roundedHigh,
                            accessibilityIdSuffix: "PendingTransactionSuccessBadge"
                        )
                    ),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.success.imageResource),
                        position: .radiusDistanceFromCenter
                    )
                )
            ),
            effect: .close,
            buttonViewModel: .primary(with: LocalizationConstants.okString)
        )
    }

    private func pending(state: TransactionState) -> PendingTransactionPageState {
        let amount = state.amount
        let currency = amount.currency
        return .init(
            title: String(
                format: LocalizationIds.Pending.title,
                amount.displayString
            ),
            subtitle: LocalizationIds.Pending.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .badgeImageViewModel(
                        .primary(
                            image: amount.currency.logoResource,
                            contentColor: .white,
                            backgroundColor: currency.isFiatCurrency ? .fiat : currency.brandColor,
                            cornerRadius: .roundedHigh,
                            accessibilityIdSuffix: "PendingTransactionPendingBadge"
                        )
                    ),
                    sideViewAttributes: .init(type: .loader, position: .radiusDistanceFromCenter),
                    cornerRadiusRatio: 0.5
                )
            ),
            buttonViewModel: nil
        )
    }

    private func failed(state: TransactionState) -> PendingTransactionPageState {
        let currency = state.amount.currency
        return .init(
            title: state.transactionErrorDescription,
            subtitle: LocalizationIds.Failure.description,
            compositeViewType: .composite(
                .init(
                    baseViewType: .badgeImageViewModel(
                        .primary(
                            image: currency.logoResource,
                            contentColor: .white,
                            backgroundColor: currency.isFiatCurrency ? .fiat : currency.brandColor,
                            cornerRadius: .roundedHigh,
                            accessibilityIdSuffix: "PendingTransactionFailureBadge"
                        )
                    ),
                    sideViewAttributes: .init(
                        type: .image(PendingStateViewModel.Image.circleError.imageResource),
                        position: .radiusDistanceFromCenter
                    )
                )
            ),
            effect: .close,
            buttonViewModel: .primary(with: LocalizationConstants.okString)
        )
    }
}
