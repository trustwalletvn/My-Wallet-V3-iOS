// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxDataSources
import ToolKit

public final class ActivityItemViewModel: IdentifiableType, Hashable {

    typealias AccessibilityId = Accessibility.Identifier.Activity
    typealias LocalizationStrings = LocalizationConstants.Activity.MainScreen.Item

    public typealias Descriptors = AssetBalanceViewModel.Value.Presentation.Descriptors

    public var identity: AnyHashable {
        event
    }

    public var descriptors: Descriptors {
        let accessibility = AccessibilityId.ActivityCell.self
        switch event.status {
        case .pending:
            return .muted(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .complete:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        case .product:
            return .activity(
                cryptoAccessiblitySuffix: accessibility.cryptoValuePrefix,
                fiatAccessiblitySuffix: accessibility.fiatValuePrefix
            )
        }
    }

    public var titleLabelContent: LabelContent {
        var text = ""
        switch event {
        case .buySell(let orderDetails):
            let prefix = orderDetails.isBuy ? LocalizationStrings.buy : LocalizationStrings.sell
            let postfix = orderDetails.isBuy ? orderDetails.outputValue.currencyType.name : orderDetails.inputValue.currencyType.name
            text = "\(prefix) \(postfix)"
        case .swap(let event):
            let pair = event.pair
            switch pair.outputCurrencyType {
            case .crypto:
                text = "\(LocalizationStrings.swap) \(pair.inputCurrencyType.displayCode) -> \(pair.outputCurrencyType.displayCode)"
            case .fiat:
                text = "\(LocalizationStrings.sell) \(pair.inputCurrencyType.displayCode) -> \(pair.outputCurrencyType.displayCode)"
            }

        case .transactional(let event):
            switch event.type {
            case .receive:
                text = LocalizationStrings.receive + " \(event.currency.displayCode)"
            case .send:
                text = LocalizationStrings.send + " \(event.currency.displayCode)"
            }
        case .fiat(let event):
            switch event.type {
            case .deposit:
                text = LocalizationStrings.deposit + " \(event.amount.displayCode)"
            case .withdrawal:
                text = LocalizationStrings.withdraw + " \(event.amount.displayCode)"
            }
        case .crypto(let event):
            switch event.type {
            case .deposit:
                text = LocalizationStrings.receive + " \(event.amount.displayCode)"
            case .withdrawal:
                text = LocalizationStrings.send + " \(event.amount.displayCode)"
            }
        }
        return .init(
            text: text,
            font: descriptors.fiatFont,
            color: descriptors.fiatTextColor,
            alignment: .left,
            accessibility: .id(AccessibilityId.ActivityCell.titleLabel)
        )
    }

    public var descriptionLabelContent: LabelContent {
        switch event.status {
        case .pending(confirmations: let confirmations):
            return .init(
                text: "\(confirmations.current) \(LocalizationStrings.of) \(confirmations.total)",
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .complete:
            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        case .product(let status):
            let failedLabelContent: LabelContent = .init(
                text: LocalizationStrings.failed,
                font: descriptors.cryptoFont,
                color: .destructive,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )

            switch status {
            case .custodial(let status):
                switch status {
                case .failed:
                    return failedLabelContent
                case .completed, .pending:
                    break
                }
            case .buySell(let status):
                if status == .failed {
                    return failedLabelContent
                }
            case .swap(let status):
                if status == .failed {
                    return failedLabelContent
                }
            }

            return .init(
                text: DateFormatter.medium.string(from: event.creationDate),
                font: descriptors.cryptoFont,
                color: descriptors.cryptoTextColor,
                alignment: .left,
                accessibility: .id(AccessibilityId.ActivityCell.descriptionLabel)
            )
        }
    }

    /// The color of the `EventType` image.
    public var eventColor: UIColor {
        switch event {
        case .buySell(let orderDetails):
            switch (orderDetails.status, orderDetails.isBuy) {
            case (.failed, _):
                return .destructive
            case (_, true):
                return orderDetails.outputValue.currencyType.brandColor
            case (_, false):
                return orderDetails.inputValue.currencyType.brandColor
            }
        case .swap(let event):
            if event.status == .failed {
                return .destructive
            }
            return event.pair.inputCurrencyType.brandColor
        case .fiat(let event):
            switch event.state {
            case .failed:
                return .destructive
            case .pending:
                return .mutedText
            case .completed:
                return event.amount.currencyType.brandColor
            }
        case .crypto(let event):
            switch event.state {
            case .failed:
                return .destructive
            case .pending:
                return .mutedText
            case .completed:
                return event.amount.currencyType.brandColor
            }
        case .transactional(let event):
            switch event.status {
            case .complete:
                return event.currency.brandColor
            case .pending:
                return .mutedText
            }
        }
    }

    /// The fill color of the `BadgeImageView`
    public var backgroundColor: UIColor {
        eventColor.withAlphaComponent(0.15)
    }

    /// The `imageName` for the `BadgeImageViewModel`
    public var imageName: String {
        switch event {
        case .buySell(let value):
            if value.status == .failed {
                return "activity-failed-icon"
            }

            return value.isBuy ? "plus-icon" : "minus-icon"
        case .fiat(let event):
            switch event.state {
            case .failed:
                return "activity-failed-icon"
            case .pending:
                return "clock-icon"
            case .completed:
                switch event.type {
                case .deposit:
                    return "deposit-icon"
                case .withdrawal:
                    return "withdraw-icon"
                }
            }
        case .crypto(let event):
            switch event.state {
            case .failed:
                return "activity-failed-icon"
            case .pending:
                return "clock-icon"
            case .completed:
                switch event.type {
                case .deposit:
                    return "receive-icon"
                case .withdrawal:
                    return "send-icon"
                }
            }
        case .swap(let event):
            if event.status == .failed {
                return "activity-failed-icon"
            }
            return "swap-icon"
        case .transactional(let event):
            switch (event.status, event.type) {
            case (.pending, _):
                return "clock-icon"
            case (_, .send):
                return "send-icon"
            case (_, .receive):
                return "receive-icon"
            }
        }
    }

    public let event: ActivityItemEvent

    public init(event: ActivityItemEvent) {
        self.event = event
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(event)
    }
}

extension ActivityItemViewModel: Equatable {
    public static func == (lhs: ActivityItemViewModel, rhs: ActivityItemViewModel) -> Bool {
        lhs.event == rhs.event
    }
}
