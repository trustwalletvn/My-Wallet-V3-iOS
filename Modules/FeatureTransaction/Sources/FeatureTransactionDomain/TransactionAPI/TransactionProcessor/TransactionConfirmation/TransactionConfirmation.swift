// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

public enum TransactionConfirmation: TransactionConfirmationModelable {

    case bitpayCountdown(TransactionConfirmation.Model.BitPayCountdown)
    case description(TransactionConfirmation.Model.Description)
    case destination(TransactionConfirmation.Model.Destination)
    case errorNotice(TransactionConfirmation.Model.ErrorNotice)
    case exchangePrice(TransactionConfirmation.Model.ExchangePriceOption)
    case feedTotal(TransactionConfirmation.Model.FeedTotal)
    case feeSelection(TransactionConfirmation.Model.FeeSelection)
    case largeTransactionWarning(TransactionConfirmation.Model.AnyBoolOption<MoneyValue>)
    case memo(TransactionConfirmation.Model.Memo)
    case transactionFee(TransactionConfirmation.Model.FiatTransactionFee)
    case arrivalDate(TransactionConfirmation.Model.FundsArrivalDate)
    case networkFee(TransactionConfirmation.Model.NetworkFee)
    case sendDestinationValue(TransactionConfirmation.Model.SendDestinationValue)
    case source(TransactionConfirmation.Model.Source)
    case swapDestinationValue(TransactionConfirmation.Model.SwapDestinationValue)
    case swapExchangeRate(TransactionConfirmation.Model.SwapExchangeRate)
    case swapSourceValue(TransactionConfirmation.Model.SwapSourceValue)
    case total(TransactionConfirmation.Model.Total)

    public var type: TransactionConfirmation.Kind {
        switch self {
        case .arrivalDate(let value):
            return value.type
        case .transactionFee(let value):
            return value.type
        case .bitpayCountdown(let value):
            return value.type
        case .description(let value):
            return value.type
        case .destination(let value):
            return value.type
        case .errorNotice(let value):
            return value.type
        case .exchangePrice(let value):
            return value.type
        case .feedTotal(let value):
            return value.type
        case .feeSelection(let value):
            return value.type
        case .largeTransactionWarning(let value):
            return value.type
        case .memo(let value):
            return value.type
        case .networkFee(let value):
            return value.type
        case .sendDestinationValue(let value):
            return value.type
        case .source(let value):
            return value.type
        case .swapDestinationValue(let value):
            return value.type
        case .swapExchangeRate(let value):
            return value.type
        case .swapSourceValue(let value):
            return value.type
        case .total(let value):
            return value.type
        }
    }

    public var formatted: (title: String, subtitle: String)? {
        switch self {
        case .arrivalDate(let value):
            return value.formatted
        case .transactionFee(let value):
            return value.formatted
        case .bitpayCountdown(let value):
            return value.formatted
        case .description(let value):
            return value.formatted
        case .destination(let value):
            return value.formatted
        case .errorNotice(let value):
            return value.formatted
        case .exchangePrice(let value):
            return value.formatted
        case .feedTotal(let value):
            return value.formatted
        case .feeSelection(let value):
            return value.formatted
        case .largeTransactionWarning(let value):
            return value.formatted
        case .memo(let value):
            return value.formatted
        case .networkFee(let value):
            return value.formatted
        case .sendDestinationValue(let value):
            return value.formatted
        case .source(let value):
            return value.formatted
        case .swapDestinationValue(let value):
            return value.formatted
        case .swapExchangeRate(let value):
            return value.formatted
        case .swapSourceValue(let value):
            return value.formatted
        case .total(let value):
            return value.formatted
        }
    }

    /// Is equal ignoring associated value.
    public func bareCompare(to rhs: Self) -> Bool {
        switch (self, rhs) {
        case (.bitpayCountdown, .bitpayCountdown),
             (.description, .description),
             (.destination, .destination),
             (.errorNotice, .errorNotice),
             (.exchangePrice, .exchangePrice),
             (.feedTotal, .feedTotal),
             (.feeSelection, .feeSelection),
             (.largeTransactionWarning, .largeTransactionWarning),
             (.memo, .memo),
             (.networkFee, .networkFee),
             (.sendDestinationValue, .sendDestinationValue),
             (.source, .source),
             (.swapDestinationValue, .swapDestinationValue),
             (.swapExchangeRate, .swapExchangeRate),
             (.swapSourceValue, .swapSourceValue),
             (.total, .total),
             (.transactionFee, .transactionFee),
             (.arrivalDate, .arrivalDate):
            return true
        default:
            return false
        }
    }
}
