// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class SwapActivityDetailsPresenter: DetailsScreenPresenterAPI {

    // MARK: - Types

    private typealias BadgeItem = BadgeAsset.Value.Interaction.BadgeItem
    private typealias BadgeType = BadgeItem.BadgeType
    private typealias LocalizedString = LocalizationConstants.Activity.Details
    private typealias AccessibilityId = Accessibility.Identifier.Activity.Details

    // MARK: - DetailsScreenPresenterAPI

    let cells: [DetailsScreen.CellType]

    let titleViewRelay: BehaviorRelay<Screen.Style.TitleView> = .init(value: .none)

    let navigationBarAppearance: DetailsScreen.NavigationBarAppearance = .defaultDark

    let navigationBarLeadingButtonAction: DetailsScreen.BarButtonAction = .default

    let navigationBarTrailingButtonAction: DetailsScreen.BarButtonAction = .default

    let reloadRelay: PublishRelay<Void> = .init()

    // MARK: - Private Properties

    private let disposeBag: DisposeBag = .init()

    // MARK: Private Properties (LabelContentPresenting)

    private let cryptoAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let valuePresenter: LineItemCellPresenting
    private let amountFromPresenter: LineItemCellPresenting
    private let amountForPresenter: LineItemCellPresenting
    private let toPresenter: LineItemCellPresenting
    private let fromPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: - Init

    init(
        event: SwapActivityItemEvent,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        cryptoAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.amounts.withdrawal.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: AccessibilityId.cryptoAmountPrefix)
        )
        dateCreatedPresenter = TransactionalLineItem.date(DateFormatter.elegantDateFormatter.string(from: event.date))
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        valuePresenter = TransactionalLineItem
            .value(event.amounts.fiatValue.displayString)
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        amountFromPresenter = TransactionalLineItem
            .amount(event.amounts.deposit.toDisplayString(includeSymbol: true))
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        amountForPresenter = TransactionalLineItem
            .for(event.amounts.withdrawal.toDisplayString(includeSymbol: true))
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        switch event.isNonCustodial {
        case true:
            toPresenter = TransactionalLineItem.to(event.kind.withdrawalAddress).defaultCopyablePresenter(
                analyticsRecorder: analyticsRecorder,
                accessibilityIdPrefix: AccessibilityId.lineItemPrefix
            )
            fromPresenter = TransactionalLineItem.from(event.depositTxHash ?? "")
                .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        case false:
            let source = event.pair.inputCurrencyType.displayCode
            let destination = event.pair.outputCurrencyType.displayCode
            toPresenter = TransactionalLineItem.to("\(destination) \(LocalizedString.wallet)")
                .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
            fromPresenter = TransactionalLineItem.from("\(source) \(LocalizedString.wallet)")
                .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        }

        titleViewRelay
            .accept(.text(value: LocalizedString.Title.swap))
        let statusDescription = event.status.localizedDescription
        let badgeType: BadgeType = event.status == .complete ? .verified : .default(accessibilitySuffix: statusDescription)
        let badgeItem: BadgeItem = .init(
            type: badgeType,
            description: statusDescription
        )
        statusBadge
            .interactor
            .stateRelay
            .accept(
                .loaded(
                    next: badgeItem
                )
            )
        badgesModel
            .badgesRelay
            .accept([statusBadge])

        var values: [DetailsScreen.CellType] = [
            .label(cryptoAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter),
            .separator,
            .lineItem(amountFromPresenter),
            .separator,
            .lineItem(amountForPresenter),
            .separator,
            .lineItem(valuePresenter),
            .separator
        ]

        switch event.isCustodial {
        case true:
            values.append(contentsOf: [
                .lineItem(fromPresenter),
                .separator,
                .lineItem(toPresenter),
                .separator
            ])
        case false:
            values.append(contentsOf: [
                .lineItem(toPresenter),
                .separator
            ])
        }

        cells = values
    }
}
