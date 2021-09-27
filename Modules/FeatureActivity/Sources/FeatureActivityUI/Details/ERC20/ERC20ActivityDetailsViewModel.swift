// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt
import ERC20Kit
import EthereumKit
import Localization
import PlatformKit
import PlatformUIKit

struct ERC20ActivityDetailsViewModel: Equatable {

    private typealias LocalizedString = LocalizationConstants.Activity.Details

    struct Confirmation: Equatable {
        fileprivate static let empty: Confirmation = .init(
            needConfirmation: false,
            title: "",
            factor: 1,
            statusBadge: ERC20ActivityDetailsViewModel.statusBadge(for: .confirmed)
        )
        let needConfirmation: Bool
        let title: String
        let factor: Float
        let statusBadge: BadgeAsset.Value.Interaction.BadgeItem
    }

    struct Amounts: Equatable {
        fileprivate static let empty: Amounts = .init(fee: .empty, gasFor: nil)

        struct Value: Equatable {
            fileprivate static let empty: Value = .init(cryptoAmount: "", amount: "", value: "")
            let cryptoAmount: String
            let amount: String
            let value: String
        }

        let fee: Value
        let gasFor: Value?
    }

    let amounts: Amounts
    let confirmation: Confirmation
    let dateCreated: String
    let from: String
    let to: String?

    init(details: EthereumActivityItemEventDetails, price: FiatValue?) {
        confirmation = Confirmation(
            needConfirmation: details.confirmation.needConfirmation,
            // swiftlint:disable line_length
            title: "\(details.confirmation.confirmations) \(LocalizedString.of) \(details.confirmation.requiredConfirmations) \(LocalizedString.confirmations)",
            factor: details.confirmation.factor,
            statusBadge: ERC20ActivityDetailsViewModel.statusBadge(for: details.confirmation.status)
        )
        let gas = ERC20ContractGasActivityModel(details: details)
        amounts = ERC20ActivityDetailsViewModel.amounts(details: details, gas: gas, price: price)
        dateCreated = DateFormatter.elegantDateFormatter.string(from: details.createdAt)
        from = details.from.publicKey
        to = gas?.to?.publicKey
    }

    private static func amounts(details: EthereumActivityItemEventDetails, gas: ERC20ContractGasActivityModel?, price: FiatValue?) -> Amounts {
        func value(cryptoValue: CryptoValue) -> Amounts.Value {
            let cryptoAmount = cryptoValue.toDisplayString(includeSymbol: true)
            let amount: String
            let value: String
            if let price = price {
                amount = "\(cryptoAmount) at \(price.displayString)"
                value = cryptoValue.convertToFiatValue(exchangeRate: price).displayString
            } else {
                amount = cryptoAmount
                value = ""
            }
            return Amounts.Value(cryptoAmount: cryptoAmount, amount: amount, value: value)
        }
        var gasFor: Amounts.Value?
        if let gasCryptoValue = gas?.cryptoValue {
            gasFor = value(cryptoValue: gasCryptoValue)
        }
        return Amounts(
            fee: value(cryptoValue: details.fee),
            gasFor: gasFor
        )
    }

    private static func statusBadge(for state: EthereumTransactionState) -> BadgeAsset.Value.Interaction.BadgeItem {
        switch state {
        case .confirmed:
            return .init(type: .verified, description: LocalizedString.completed)
        case .pending:
            return .init(type: .default(accessibilitySuffix: "Pending"), description: LocalizedString.pending)
        case .replaced:
            return .init(type: .verified, description: LocalizedString.replaced)
        }
    }
}
