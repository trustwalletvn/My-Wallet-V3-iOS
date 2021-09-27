// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit

extension TransactionConfirmation {
    public enum Model {}
}

extension TransactionConfirmation.Model {
    private typealias LocalizedString = LocalizationConstants.Transaction.Confirmation

    public struct ExchangePriceOption: TransactionConfirmationModelable {
        public let money: MoneyValue
        public let currency: CryptoCurrency
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (
                String(format: LocalizedString.price, currency.displayCode),
                money.displayString
            )
        }
    }

    public struct FeedTotal: TransactionConfirmationModelable {
        public let amount: MoneyValue
        public let amountInFiat: MoneyValue
        public let fee: MoneyValue
        public let feeInFiat: MoneyValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.total, amountString)
        }

        public init(
            amount: MoneyValue,
            amountInFiat: MoneyValue,
            fee: MoneyValue,
            feeInFiat: MoneyValue
        ) {
            self.amount = amount
            self.amountInFiat = amountInFiat
            self.fee = fee
            self.feeInFiat = feeInFiat
        }

        private var amountString: String {
            if amount.currency == fee.currency {
                return amountStringSameCurrency
            } else {
                return amountStringDifferentCurrencies
            }
        }

        private var amountStringSameCurrency: String {
            guard let total = try? amount + fee else {
                return ""
            }
            guard let totalFiat = try? amountInFiat + feeInFiat else {
                return ""
            }
            return "\(total.displayString) (\(totalFiat.displayString))"
        }

        private var amountStringDifferentCurrencies: String {
            "\(amount.displayString) (\(amountInFiat.displayString))\n\(fee.displayString) (\(feeInFiat.displayString))"
        }
    }

    public struct Total: TransactionConfirmationModelable {
        public let total: MoneyValue
        public let exchange: MoneyValue?
        public let type: TransactionConfirmation.Kind = .readOnly

        public init(total: MoneyValue, exchange: MoneyValue? = nil) {
            self.total = total
            self.exchange = exchange
        }

        public var formatted: (title: String, subtitle: String)? {
            var value: String = total.displayString
            if let exchange = exchange,
               let converted = try? total.convert(using: exchange)
            {
                value = converted.displayString
            }
            return (LocalizedString.total, value)
        }
    }

    public struct Destination: TransactionConfirmationModelable {
        public let value: String
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.to, value)
        }

        public init(value: String) {
            self.value = value
        }
    }

    public struct Source: TransactionConfirmationModelable {
        public let value: String
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.from, value)
        }

        public init(value: String) {
            self.value = value
        }
    }

    public struct FeeSelection: TransactionConfirmationModelable {
        public let feeState: FeeState
        public let selectedLevel: FeeLevel
        public let fee: MoneyValue?
        public let type: TransactionConfirmation.Kind = .feeSelection

        public var formatted: (title: String, subtitle: String)? {
            let subtitle = fee?.toDisplayString(includeSymbol: true) ?? ""
            let title = LocalizedString.transactionFee(feeType: selectedLevel.title)
            return (title, subtitle)
        }

        public init(feeState: FeeState, selectedLevel: FeeLevel, fee: MoneyValue?) {
            self.feeState = feeState
            self.selectedLevel = selectedLevel
            self.fee = fee
        }
    }

    public struct BitPayCountdown: TransactionConfirmationModelable {
        public let secondsRemaining: TimeInterval
        public let type: TransactionConfirmation.Kind = .invoiceCountdown

        private let countdownFormatter: DateComponentsFormatter

        init(secondsRemaining: TimeInterval, countdownFormatter: DateComponentsFormatter = .countdownFormatter) {
            self.secondsRemaining = secondsRemaining
            self.countdownFormatter = countdownFormatter
        }

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.remainingTime, countdownFormatter.string(from: secondsRemaining) ?? "")
        }
    }

    public struct ErrorNotice: TransactionConfirmationModelable {
        public let validationState: TransactionValidationState
        public let type: TransactionConfirmation.Kind = .errorNotice
        public let moneyValue: MoneyValue?

        public init(validationState: TransactionValidationState, moneyValue: MoneyValue?) {
            self.validationState = validationState
            self.moneyValue = moneyValue
        }

        /// By the time we are on the confirmation screen most of these possible error should have been
        /// filtered out. A few remain possible, because BE failures or BitPay invoices, thus:
        /// - Note: At the UI level the title is ignored,
        /// check the `errorModels` in `ConfirmationPageContentReducer` in `FeatureTransactionUI`.
        public var formatted: (title: String, subtitle: String)? {
            switch validationState {
            case .canExecute, .uninitialized:
                return nil
            case .belowMinimumLimit:
                let message: String
                if let value = moneyValue {
                    message = String(
                        format: LocalizedString.Error.underMinLimit,
                        value.toDisplayString(includeSymbol: true)
                    )
                } else {
                    message = LocalizedString.Error.underMinBitcoinFee
                }
                return (LocalizedString.Error.title, message)
            case .insufficientFunds:
                return (LocalizedString.Error.title, LocalizedString.Error.insufficientFunds)
            case .insufficientGas:
                return (LocalizedString.Error.title, LocalizedString.Error.insufficientGas)
            case .invalidAmount:
                return (LocalizedString.Error.title, LocalizedString.Error.invalidAmount)
            case .invoiceExpired:
                return (LocalizedString.Error.title, LocalizedString.Error.invoiceExpired)
            case .transactionInFlight:
                return (LocalizedString.Error.title, LocalizedString.Error.transactionInFlight)
            case .overMaximumLimit:
                return (LocalizedString.Error.title, LocalizedString.Error.overMaximumLimit)
            // these should be filtered out by now
            case .addressIsContract:
                return (LocalizedString.Error.title, LocalizationConstants.Transaction.Error.addressIsContract)
            case .invalidAddress:
                return (LocalizedString.Error.title, LocalizationConstants.Transaction.Error.invalidAddress)
            case .optionInvalid:
                return (LocalizedString.Error.title, LocalizationConstants.Transaction.Error.optionInvalid)
            case .insufficientFundsForFees,
                 .overGoldTierLimit,
                 .overSilverTierLimit,
                 .unknownError:
                return (LocalizedString.Error.title, LocalizedString.Error.generic)
            case .pendingOrdersLimitReached:
                return (LocalizedString.Error.title, LocalizedString.Error.pendingOrderLimitReached)
            case .nabuError(let error):
                let errorCode = String(format: LocalizationConstants.Errors.errorCode, error.code.rawValue)
                let rawNabuDescription = error.description ?? "\(LocalizedString.Error.generic). \(errorCode)"
                return (LocalizedString.Error.title, rawNabuDescription)
            }
        }
    }

    public struct Description: TransactionConfirmationModelable {
        public let value: String
        public let type: TransactionConfirmation.Kind = .description

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.description, value)
        }

        public init(value: String = "") {
            self.value = value
        }
    }

    public struct Memo: TransactionConfirmationModelable {
        public enum Value: Equatable {
            case text(String)
            case identifier(Int)

            public static func == (lhs: Value, rhs: Value) -> Bool {
                switch (lhs, rhs) {
                case (.text(let lhs), .text(let rhs)):
                    return lhs == rhs
                case (.identifier(let lhs), .identifier(let rhs)):
                    return lhs == rhs
                default:
                    return false
                }
            }

            var string: String {
                switch self {
                case .text(let string):
                    return string
                case .identifier(let identifier):
                    return String(identifier)
                }
            }
        }

        public let value: Value?
        public let required: Bool
        public let type: TransactionConfirmation.Kind = .memo

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.memo, value?.string ?? "")
        }

        public init(textMemo: String?, required: Bool) {
            value = textMemo.flatMap { Value.text($0) }
            self.required = required
        }
    }

    public struct SwapSourceValue: TransactionConfirmationModelable {
        public let cryptoValue: CryptoValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizationConstants.Transaction.Swap.swap, cryptoValue.displayString)
        }
    }

    public struct SwapDestinationValue: TransactionConfirmationModelable {
        public let cryptoValue: CryptoValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizationConstants.Transaction.receive, cryptoValue.displayString)
        }
    }

    public struct SendDestinationValue: TransactionConfirmationModelable {
        public let value: MoneyValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizationConstants.Transaction.Send.send, value.displayString)
        }

        public init(value: MoneyValue) {
            self.value = value
        }
    }

    public struct SwapExchangeRate: TransactionConfirmationModelable {
        public let baseValue: MoneyValue
        public let resultValue: MoneyValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.exchangeRate, "\(baseValue.displayString) = \(resultValue.displayString)")
        }
    }

    public struct FundsArrivalDate: TransactionConfirmationModelable {

        /// Defaults to five days. Applies to both `deposit` and `withdraw`.
        public static let `default`: FundsArrivalDate = .init()

        public let date: Date
        public let type: TransactionConfirmation.Kind = .readOnly

        public init(date: Date = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()) {
            self.date = date
        }

        public var formatted: (title: String, subtitle: String)? {
            (LocalizedString.fundsArrivalDate, "\(DateFormatter.medium.string(from: date))")
        }
    }

    public struct FiatTransactionFee: TransactionConfirmationModelable {
        public let fee: MoneyValue
        public let type: TransactionConfirmation.Kind = .readOnly

        public var formatted: (title: String, subtitle: String)? {
            (
                String(format: LocalizedString.transactionFee, fee.displayCode),
                fee.displayString
            )
        }
    }

    public struct NetworkFee: TransactionConfirmationModelable {
        public enum FeeType {
            case depositFee
            case withdrawalFee
        }

        public let fee: MoneyValue
        public let feeType: FeeType
        public let asset: CurrencyType
        public let type: TransactionConfirmation.Kind = .networkFee

        public var formatted: (title: String, subtitle: String)? {
            (
                String(format: LocalizedString.networkFee, asset.displayCode),
                fee.displayString
            )
        }
    }

    public struct AnyBoolOption<T: Equatable>: TransactionConfirmationModelable {
        public let data: T?
        public let value: Bool
        public let type: TransactionConfirmation.Kind

        public var formatted: (title: String, subtitle: String)? {
            ("\(value) Data", "\(data.debugDescription)")
        }

        public init(value: Bool, type: TransactionConfirmation.Kind, data: T? = nil) {
            self.value = value
            self.data = data
            self.type = type
        }
    }
}
