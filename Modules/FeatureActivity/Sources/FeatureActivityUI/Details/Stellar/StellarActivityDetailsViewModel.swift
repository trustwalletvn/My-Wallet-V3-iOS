// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import PlatformUIKit
import StellarKit

struct StellarActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    let amount: String
    let cryptoAmount: String
    let dateCreated: String
    let fee: String?
    let from: String
    let memo: String
    let statusBadge: BadgeAsset.Value.Interaction.BadgeItem?
    let to: String
    let transactionHash: String
    let value: String

    init(with details: StellarActivityItemEventDetails, price: FiatValue?) {
        transactionHash = details.transactionHash
        cryptoAmount = details.cryptoAmount.toDisplayString(includeSymbol: true)
        if let price = price {
            amount = "\(cryptoAmount) at \(price.displayString)"
            value = details.cryptoAmount.convertToFiatValue(exchangeRate: price).displayString
        } else {
            amount = cryptoAmount
            value = ""
        }
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        from = details.from
        to = details.to

        fee = details.fee?.toDisplayString(includeSymbol: true)
        memo = details.memo ?? LocalizedString.noDescription
        statusBadge = .init(type: .verified, description: LocalizedString.completed)
    }
}
