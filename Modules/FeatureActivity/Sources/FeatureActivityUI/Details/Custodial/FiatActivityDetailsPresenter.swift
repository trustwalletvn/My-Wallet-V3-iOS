// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxRelay
import RxSwift
import ToolKit

final class FiatActivityDetailsPresenter: DetailsScreenPresenterAPI {

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

    private let fiatAmountLabelPresenter: LabelContentPresenting

    // MARK: Private Properties (LineItemCellPresenting)

    private let dateCreatedPresenter: LineItemCellPresenting
    private let orderIDPresenter: LineItemCellPresenting

    // MARK: Private Properties (Badge Model)

    private let badgesModel = MultiBadgeViewModel()
    private let statusBadge: DefaultBadgeAssetPresenter = .init()

    // MARK: - Init

    init(
        event: CustodialActivityEvent.Fiat,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        fiatAmountLabelPresenter = DefaultLabelContentPresenter(
            knownValue: event.amount.toDisplayString(includeSymbol: true),
            descriptors: .h1(accessibilityIdPrefix: "")
        )
        dateCreatedPresenter = TransactionalLineItem.date(DateFormatter.elegantDateFormatter.string(from: event.date))
            .defaultPresenter(accessibilityIdPrefix: AccessibilityId.lineItemPrefix)
        orderIDPresenter = TransactionalLineItem.orderId(event.identifier).defaultCopyablePresenter(
            analyticsRecorder: analyticsRecorder,
            accessibilityIdPrefix: AccessibilityId.lineItemPrefix
        )

        let title: String
        let statusDescription: String
        let badgeType: BadgeType
        switch event.type {
        case .deposit:
            title = LocalizedString.Title.deposit
        case .withdrawal:
            title = LocalizedString.Title.withdraw
        }
        switch event.state {
        case .completed:
            statusDescription = LocalizedString.completed
            badgeType = .verified
        case .pending:
            statusDescription = LocalizedString.pending
            badgeType = .default(accessibilitySuffix: statusDescription)
        case .failed:
            statusDescription = LocalizedString.failed
            badgeType = .destructive
        }

        titleViewRelay.accept(.text(value: title))
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

        cells = [
            .label(fiatAmountLabelPresenter),
            .badges(badgesModel),
            .separator,
            .lineItem(orderIDPresenter),
            .separator,
            .lineItem(dateCreatedPresenter)
        ]
    }
}
