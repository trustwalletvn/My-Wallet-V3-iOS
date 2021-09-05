// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import ToolKit
import TransactionKit

struct TransactionState: StateType {

    // MARK: Actual Transaction Data

    let action: AssetAction

    var availableSources: [BlockchainAccount] = []
    var availableTargets: [TransactionTarget] = []

    var source: BlockchainAccount?
    var destination: TransactionTarget?

    var sourceDestinationPair: MoneyValuePair?

    var sourceToFiatPair: MoneyValuePair?
    var destinationToFiatPair: MoneyValuePair?

    // MARK: Execution Supporting Data

    var pendingTransaction: PendingTransaction?
    var executionStatus: TransactionExecutionStatus = .notStarted
    var errorState: TransactionErrorState = .none // TODO: make it associated data of execution status, if related?

    // MARK: UI Supporting Data

    var allowFiatInput: Bool = false

    // MARK: Second Password Supporting Data

    var passwordRequired: Bool = false
    var secondPassword: String = ""

    // MARK: Navigation Supporting Data

    var nextEnabled: Bool = false
    var isGoingBack: Bool = false

    var step: TransactionFlowStep = .initial {
        didSet {
            isGoingBack = false
        }
    }

    var stepsBackStack: [TransactionFlowStep] = []
}

extension TransactionState: Equatable {

    static func == (lhs: TransactionState, rhs: TransactionState) -> Bool {
        lhs.action == rhs.action
            && lhs.allowFiatInput == rhs.allowFiatInput
            && lhs.destination?.label == rhs.destination?.label
            && lhs.destinationToFiatPair == rhs.destinationToFiatPair
            && lhs.errorState == rhs.errorState
            && lhs.executionStatus == rhs.executionStatus
            && lhs.isGoingBack == rhs.isGoingBack
            && lhs.nextEnabled == rhs.nextEnabled
            && lhs.passwordRequired == rhs.passwordRequired
            && lhs.pendingTransaction == rhs.pendingTransaction
            && lhs.secondPassword == rhs.secondPassword
            && lhs.source?.identifier == rhs.source?.identifier
            && lhs.sourceDestinationPair == rhs.sourceDestinationPair
            && lhs.sourceToFiatPair == rhs.sourceToFiatPair
            && lhs.step == rhs.step
            && lhs.stepsBackStack == rhs.stepsBackStack
            && lhs.availableSources.map(\.identifier) == rhs.availableSources.map(\.identifier)
            && lhs.availableTargets.map(\.label) == rhs.availableTargets.map(\.label)
    }
}

extension TransactionState {

    /// The source account `CryptoCurrency`.
    var asset: CurrencyType {
        guard let sourceAccount = source else {
            preconditionFailure("Source should have been set at this point.")
        }
        guard let account = sourceAccount as? SingleAccount else {
            preconditionFailure("Expected a `SingleAccount`: \(String(describing: source))")
        }
        return account.currencyType
    }

    /// The fees associated with the transaction
    var feeSelection: FeeSelection {
        guard let pendingTx = pendingTransaction else {
            /// If there is no `pendingTransaction` then the
            /// available fee levels is `[.none]`
            return .empty(asset: asset)
        }
        return pendingTx.feeSelection
    }

    /// The amount the user is swapping from.
    var amount: MoneyValue {
        pendingTransaction?.amount ?? .zero(currency: asset)
    }

    /// The minimum spending limit
    var minSpendable: MoneyValue {
        pendingTransaction?.minimumLimit ?? .zero(currency: asset)
    }

    /// The maximum amount the user can use daily for the given transaction.
    /// This is a different value than the spendable amount (and usually higher)
    var maxDaily: MoneyValue {
        pendingTransaction?.maximumDailyLimit ?? .zero(currency: asset)
    }

    /// The maximum amount the user can spend. We compare the amount entered to the
    /// `maxLimit` as `CryptoValues` and return whichever is smaller.
    var maxSpendable: MoneyValue {
        pendingTransaction?.maxSpendable ?? .zero(currency: asset)
    }

    /// The balance in `MoneyValue` based on the `PendingTransaction`
    var availableBalance: MoneyValue {
        pendingTransaction?.available ?? .zero(currency: asset)
    }

    func moneyValueFromSource() -> Result<MoneyValue, TransactionUIKitError> {
        guard let rate = sourceToFiatPair else {
            /// A `sourceToFiatPair` is not provided for transactions like a
            /// deposit or a withdraw.
            return .success(amount)
        }
        guard let currencyType = rate.base.cryptoValue?.currencyType else {
            return .failure(.unexpectedMoneyValueType(rate.base))
        }
        guard let quote = rate.quote.fiatValue else {
            return .failure(.unexpectedMoneyValueType(rate.quote))
        }
        switch (amount.cryptoValue, amount.fiatValue) {
        case (.some(let amount), .none):
            /// Just show the `CryptoValue` that the user entered
            /// as this is the `source` currency.
            return .success(.init(cryptoValue: amount))
        case (.none, .some(let amount)):
            /// Convert the `FiatValue` to a `CryptoValue` given the
            /// `quote` from the `sourceToFiatPair` exchange rate.
            return .success(amount
                .convertToCryptoValue(
                    exchangeRate: quote,
                    cryptoCurrency: currencyType
                )
                .moneyValue
            )
        default:
            break
        }
        return .success(.zero(currency: currencyType))
    }

    /// The `MoneyValue` representing the amount received
    /// or the amount that is sent to the given destination.
    func moneyValueFromDestination() -> Result<MoneyValue, TransactionUIKitError> {
        let currencyType: CurrencyType
        switch destination {
        case let account as SingleAccount:
            currencyType = account.currencyType
        case let receiveAddress as CryptoReceiveAddress:
            currencyType = receiveAddress.asset.currency
        default:
            return .failure(.unexpectedDestinationAccountType)
        }
        guard let exchange = sourceDestinationPair else {
            return .success(.zero(currency: currencyType))
        }
        guard case .crypto(let currency) = exchange.quote.currencyType else {
            return .failure(.unexpectedCurrencyType(exchange.quote.currencyType))
        }
        guard let sourceQuote = sourceToFiatPair?.quote.fiatValue else {
            return .failure(.emptySourceExchangeRate)
        }
        guard let destinationQuote = destinationToFiatPair?.quote.fiatValue else {
            return .failure(.emptyDestinationExchangeRate)
        }

        switch (
            amount.cryptoValue,
            amount.fiatValue,
            exchange.quote.cryptoValue
        ) {
        case (.none, .some(let fiat), .some(let cryptoPrice)):
            /// Conver the `fiatValue` amount entered into
            /// a `CryptoValue`
            return .success(
                fiat.convertToCryptoValue(
                    exchangeRate: destinationQuote,
                    cryptoCurrency: cryptoPrice.currencyType
                )
                .moneyValue
            )
        case (.some(let crypto), .none, _):
            /// Convert the `cryptoValue` input into a `fiatValue` type.
            let fiat = crypto.convertToFiatValue(exchangeRate: sourceQuote)
            /// Convert the `fiatValue` input into a `cryptoValue` type
            /// given the `quote` of the `destinationCurrencyType`.
            return .success(
                fiat.convertToCryptoValue(
                    exchangeRate: destinationQuote,
                    cryptoCurrency: currency
                )
                .moneyValue
            )
        default:
            return .success(.zero(currency: currency))
        }
    }

    /// Converts an FiatValue `available` into CryptoValue if necessary.
    private func availableToAmountCurrency(available: MoneyValue, amount: MoneyValue) throws -> MoneyValue {
        guard amount.isFiat else {
            return available
        }
        guard let rate = sourceToFiatPair else {
            return .zero(currency: amount.currency)
        }
        return try available.convert(using: rate.quote)
    }
}

extension TransactionState {

    private typealias LocalizationIds = LocalizationConstants.Transaction.Error

    var transactionErrorDescription: String {
        switch errorState {
        case .none:
            #if INTERNAL_BUILD
            Logger.shared.error("Unsupported API error thrown or an internal error thrown")
            fatalError("Please map to appropriate error code.")
            #endif
            return LocalizationIds.unknownError
        case .addressIsContract:
            return LocalizationIds.addressIsContract
        case .belowMinimumLimit:
            return String(format: LocalizationIds.tradingBelowMin, action.name)
        case .insufficientFunds:
            return LocalizationIds.insufficientFunds
        case .insufficientGas:
            return LocalizationIds.insufficientGas
        case .insufficientFundsForFees:
            return String(format: LocalizationIds.insufficientFundsForFees, amount.currency.name)
        case .invalidAddress:
            return LocalizationIds.invalidAddress
        case .invalidAmount:
            return LocalizationIds.invalidAmount
        case .invalidPassword:
            return LocalizationIds.invalidPassword
        case .optionInvalid:
            return LocalizationIds.optionInvalid
        case .overGoldTierLimit,
             .overMaximumLimit,
             .overSilverTierLimit:
            return LocalizationIds.overMaximumLimit
        case .pendingOrdersLimitReached:
            return LocalizationIds.pendingOrderLimitReached
        case .transactionInFlight:
            return LocalizationIds.transactionInFlight
        case .fatalError(let fatalTransactionError):
            switch fatalTransactionError {
            case .generic(let error):
                guard let networkError = error as? NabuNetworkError else {
                    return LocalizationIds.unknownError
                }
                guard case .nabuError(let nabu) = networkError else {
                    return LocalizationIds.unknownError
                }

                return transactionErrorDescriptionForError(nabu.code)
            case .rxError:
                return LocalizationIds.unknownError
            }
        case .unknownError:
            return LocalizationIds.unknownError
        case .nabuError(let error):
            return transactionErrorDescriptionForError(error.code)
        }
    }

    private func transactionErrorDescriptionForError(_ code: NabuErrorCode) -> String {
        switch code {
        case .orderBelowMinLimit:
            return String(format: LocalizationIds.tradingBelowMin, action.name)
        case .orderAboveMaxLimit:
            return String(format: LocalizationIds.tradingAboveMax, action.name)
        case .dailyLimitExceeded:
            return String(format: LocalizationIds.tradingDailyExceeded, action.name)
        case .weeklyLimitExceeded:
            return String(format: LocalizationIds.tradingWeeklyExceeded, action.name)
        case .annualLimitExceeded:
            return String(format: LocalizationIds.tradingYearlyExceeded, action.name)
        case .tradingDisabled:
            return LocalizationIds.tradingServiceDisabled
        case .pendingOrdersLimitReached:
            return LocalizationIds.pendingOrderLimitReached
        case .invalidCryptoAddress:
            return LocalizationIds.tradingInvalidAddress
        case .invalidCryptoCurrency:
            return LocalizationIds.tradingInvalidCurrency
        case .invalidFiatCurrency:
            return LocalizationIds.tradingInvalidFiat
        case .orderDirectionDisabled:
            return LocalizationIds.tradingDirectionDisabled
        case .userNotEligibleForSwap:
            return LocalizationIds.tradingIneligibleForSwap
        case .invalidDestinationAddress:
            return LocalizationIds.tradingInvalidAddress
        case .notFoundCustodialQuote:
            return LocalizationIds.tradingQuoteInvalidOrExpired
        case .orderAmountNegative:
            return LocalizationIds.tradingInvalidDestinationAmount
        case .withdrawalForbidden:
            return LocalizationIds.pendingWithdraw
        case .withdrawalLocked:
            return LocalizationIds.withdrawBalanceLocked
        case .insufficientBalance:
            return String(format: LocalizationIds.tradingInsufficientBalance, action.name)
        case .albertExecutionError:
            return LocalizationIds.tradingAlbertError
        case .orderInProgress:
            return String(format: LocalizationIds.tooManyTransaction, action.name)
        default:
            return LocalizationIds.unknownError
        }
    }
}

enum TransactionFlowStep: Equatable {
    case initial
    case enterPassword
    case selectSource
    case linkABank
    case enterAddress
    case selectTarget
    case enterAmount
    case kycChecks
    case confirmDetail
    case inProgress
    case closed

    var addToBackStack: Bool {
        switch self {
        case .selectSource,
             .selectTarget,
             .enterAddress,
             .enterAmount:
            return true
        case .closed,
             .confirmDetail,
             .enterPassword,
             .inProgress,
             .initial,
             .kycChecks,
             .linkABank:
            return false
        }
    }
}

enum TransactionExecutionStatus {
    case notStarted
    case inProgress
    case error
    case completed

    var isComplete: Bool {
        self == .completed
    }
}
