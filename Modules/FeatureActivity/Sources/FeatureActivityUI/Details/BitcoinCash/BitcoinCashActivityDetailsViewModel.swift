// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BitcoinCashKit
import Localization
import PlatformKit
import PlatformUIKit

struct BitcoinCashActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    struct Confirmation: Equatable {
        fileprivate static let empty: Confirmation = .init(
            needConfirmation: false,
            title: "",
            factor: 1,
            statusBadge: BitcoinCashActivityDetailsViewModel.statusBadge(needConfirmation: false)
        )
        let needConfirmation: Bool
        let title: String
        let factor: Float
        let statusBadge: BadgeAsset.Value.Interaction.BadgeItem
    }

    let confirmation: Confirmation
    let dateCreated: String
    let from: String
    let to: String
    let cryptoAmount: String
    let amount: String
    let value: String
    let fee: String

    init(details: BitcoinCashActivityItemEventDetails, price: FiatValue?) {
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            // swiftlint:disable line_length
            title: "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)",
            factor: details.confirmation.factor,
            statusBadge: BitcoinCashActivityDetailsViewModel.statusBadge(needConfirmation: details.confirmation.needConfirmation)
        )
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        from = details.from.publicKey
        to = details.to.publicKey

        cryptoAmount = details.amount.toDisplayString(includeSymbol: true)
        if let price = price {
            amount = "\(cryptoAmount) at \(price.displayString)"
            value = details.amount.convertToFiatValue(exchangeRate: price).displayString
        } else {
            amount = cryptoAmount
            value = ""
        }
        fee = details.fee.toDisplayString(includeSymbol: true)
    }

    private static func statusBadge(needConfirmation: Bool) -> BadgeAsset.Value.Interaction.BadgeItem {
        if needConfirmation {
            return .init(
                type: .default(accessibilitySuffix: "Pending"),
                description: LocalizedString.pending
            )
        } else {
            return .init(type: .verified, description: LocalizedString.completed)
        }
    }
}
