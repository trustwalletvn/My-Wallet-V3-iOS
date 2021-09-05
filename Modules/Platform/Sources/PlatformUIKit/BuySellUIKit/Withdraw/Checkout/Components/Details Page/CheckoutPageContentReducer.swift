// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class CheckoutPageContentReducer: CheckoutPageContentReducing {

    // MARK: - Types

    private typealias CellInteractor = DefaultLineItemCellInteractor
    private typealias TitleLabelInteractor = DefaultLabelContentInteractor
    private typealias DescriptionLabelInteractor = DefaultLabelContentInteractor

    private typealias LocalizedString = LocalizationConstants.FiatWithdrawal.Checkout
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional
    private typealias LocalizedSummary = LocalizedString.Summary
    private typealias AccessibilityLineItem = Accessibility.Identifier.LineItem
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.Checkout
    private typealias LineItem = TransactionalLineItem

    // MARK: - CheckoutScreenContentReducing

    let title: String
    let cells: [DetailsScreen.CellType]
    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel

    // MARK: - Private Properties

    private let inputLabelContentPresenter: DefaultLabelContentPresenter
    private let fromLineItemCellPresenter: DefaultLineItemCellPresenter
    private let toLineItemCellPresenter: DefaultLineItemCellPresenter
    private let feeLineItemCellPresenter: DefaultLineItemCellPresenter
    private let totalLineItemCellPresenter: DefaultLineItemCellPresenter

    init(data: WithdrawalCheckoutData) {
        title = LocalizedString.Title.checkout

        inputLabelContentPresenter = DefaultLabelContentPresenter(
            interactor: DefaultLabelContentInteractor(
                knownValue: "\(data.amount.toDisplayString(includeSymbol: true))"),
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let fromLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.from),
            description: DescriptionLabelInteractor(
                knownValue: "\(data.currency.displayCode) \(LocalizedLineItem.wallet)"
            )
        )

        let toLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.to),
            description: DescriptionLabelInteractor(
                knownValue: "\(data.beneficiary.name) \(data.beneficiary.account)"
            )
        )

        let feeLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.fee),
            description: DescriptionLabelInteractor(
                knownValue: "\(data.fee.toDisplayString(includeSymbol: true))"
            )
        )

        let totalLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.total),
            description: TitleLabelInteractor(
                knownValue: data.amount.toDisplayString(includeSymbol: true)
            )
        )

        // TODO: Accessibility
        fromLineItemCellPresenter = .init(interactor: fromLineItemCellInteractor, accessibilityIdPrefix: "")
        toLineItemCellPresenter = .init(interactor: toLineItemCellInteractor, accessibilityIdPrefix: "")
        feeLineItemCellPresenter = .init(interactor: feeLineItemCellInteractor, accessibilityIdPrefix: "")
        totalLineItemCellPresenter = .init(interactor: totalLineItemCellInteractor, accessibilityIdPrefix: "")

        cells = [
            .label(inputLabelContentPresenter),
            .separator,
            .lineItem(fromLineItemCellPresenter),
            .separator,
            .lineItem(toLineItemCellPresenter),
            .separator,
            .lineItem(feeLineItemCellPresenter),
            .separator,
            .lineItem(totalLineItemCellPresenter)
        ]

        cancelButtonViewModel = .cancel(with: LocalizationConstants.cancel)

        let continueButtonTitle = String(
            format: LocalizedString.Button.withdrawTitle,
            data.amount.toDisplayString(includeSymbol: true)
        )
        continueButtonViewModel = .primary(with: continueButtonTitle)
    }
}
