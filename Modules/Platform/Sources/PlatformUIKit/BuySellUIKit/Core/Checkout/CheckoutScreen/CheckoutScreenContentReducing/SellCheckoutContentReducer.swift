// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class SellCheckoutContentReducer: CheckoutScreenContentReducing {

    // MARK: - Types

    private typealias CellInteractor = DefaultLineItemCellInteractor
    private typealias TitleLabelInteractor = DefaultLabelContentInteractor
    private typealias DescriptionLabelInteractor = DefaultLabelContentInteractor

    private typealias LocalizedString = LocalizationConstants.SimpleBuy.Checkout
    private typealias LocalizedLineItem = LocalizationConstants.LineItem.Transactional
    private typealias LocalizedSummary = LocalizedString.Summary
    private typealias AccessibilityLineItem = Accessibility.Identifier.LineItem
    private typealias AccessibilityId = Accessibility.Identifier.SimpleBuy.Checkout
    private typealias LineItem = TransactionalLineItem

    // MARK: - CheckoutScreenContentReducing

    let title: String
    let cells: [DetailsScreen.CellType]
    let continueButtonViewModel: ButtonViewModel
    let cancelButtonViewModel: ButtonViewModel?
    let transferDetailsButtonViewModel: ButtonViewModel? = nil

    // MARK: - Private Properties

    private let inputLabelContentPresenter: DefaultLabelContentPresenter
    private let priceLineItemCellPresenter: DefaultLineItemCellPresenter
    private let fromLineItemCellPresenter: DefaultLineItemCellPresenter
    private let toLineItemCellPresenter: DefaultLineItemCellPresenter
    private let totalLineItemCellPresenter: DefaultLineItemCellPresenter

    init(data: CheckoutData) {
        title = LocalizedString.Title.checkout

        inputLabelContentPresenter = DefaultLabelContentPresenter(
            interactor: DefaultLabelContentInteractor(
                knownValue: "\(data.order.inputValue.toDisplayString(includeSymbol: true))"),
            descriptors: .h1(accessibilityIdPrefix: "")
        )

        let priceLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: "\(data.inputCurrency.code) \(LocalizedLineItem.price)"),
            description: CheckoutContentDescriptionLabelInteractor.AssetPrice(
                service: PriceService(),
                baseCurrency: data.outputCurrency,
                quoteCurrency: data.inputCurrency
            )
        )

        let fromLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.from),
            description: DescriptionLabelInteractor(
                knownValue: "\(data.inputCurrency.code) \(LocalizedLineItem.tradingWallet)"
            )
        )

        let toLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.to),
            description: DescriptionLabelInteractor(
                knownValue: "\(data.outputCurrency.code) \(LocalizedLineItem.wallet)"
            )
        )

        let totalLineItemCellInteractor: CellInteractor = .init(
            title: TitleLabelInteractor(knownValue: LocalizedLineItem.total),
            description: TitleLabelInteractor(
                knownValue: data.order.outputValue.toDisplayString(includeSymbol: true)
            )
        )

        // TODO: Accessibility
        priceLineItemCellPresenter = .init(interactor: priceLineItemCellInteractor, accessibilityIdPrefix: "")
        fromLineItemCellPresenter = .init(interactor: fromLineItemCellInteractor, accessibilityIdPrefix: "")
        toLineItemCellPresenter = .init(interactor: toLineItemCellInteractor, accessibilityIdPrefix: "")
        totalLineItemCellPresenter = .init(interactor: totalLineItemCellInteractor, accessibilityIdPrefix: "")

        cells = [
            .label(inputLabelContentPresenter),
            .separator,
            .lineItem(priceLineItemCellPresenter),
            .separator,
            .lineItem(fromLineItemCellPresenter),
            .separator,
            .lineItem(toLineItemCellPresenter),
            .separator,
            .lineItem(totalLineItemCellPresenter)
        ]

        cancelButtonViewModel = .cancel(with: LocalizationConstants.cancel)
        continueButtonViewModel = .primary(with: "\(LocalizedSummary.sellButtonPrefix) \(data.order.inputValue.toDisplayString(includeSymbol: true))")
    }

    func setupDidSucceed(with data: CheckoutInteractionData) {
        // NO-OP
    }
}
