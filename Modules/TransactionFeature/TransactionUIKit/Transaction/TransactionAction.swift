// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformKit
import RxSwift
import ToolKit
import TransactionKit

enum TransactionAction: MviAction {

    case initialiseWithNoSourceOrTargetAccount(action: AssetAction, passwordRequired: Bool)
    case initialiseWithSourceAccount(action: AssetAction, sourceAccount: BlockchainAccount, passwordRequired: Bool)
    case initialiseWithSourceAndPreferredTarget(
        action: AssetAction,
        sourceAccount: BlockchainAccount,
        target: TransactionTarget,
        passwordRequired: Bool
    )
    case initialiseWithSourceAndTargetAccount(
        action: AssetAction,
        sourceAccount: BlockchainAccount,
        target: TransactionTarget,
        passwordRequired: Bool
    )
    case initialiseWithTargetAndNoSource(action: AssetAction, target: TransactionTarget, passwordRequired: Bool)
    case bankLinkingFlowDismissed(AssetAction)
    case showBankLinkingFlow
    case bankAccountLinkedFromSource(BlockchainAccount, AssetAction)
    case bankAccountLinked(AssetAction)
    case sourceAccountSelected(BlockchainAccount)
    case targetAccountSelected(TransactionTarget)
    case availableSourceAccountsListUpdated([BlockchainAccount])
    case availableDestinationAccountsListUpdated([BlockchainAccount])
    case updateAmount(MoneyValue) // Anytime the amount changes
    case pendingTransactionUpdated(PendingTransaction)
    case performKYCChecks
    case prepareTransaction // When continue button is tapped on enter amount screen
    case executeTransaction
    case updateTransactionComplete(TransactionResult)
    case fetchFiatRates
    case fetchTargetRates
    case updateFeeLevelAndAmount(FeeLevel, MoneyValue?)
    case sourceDestinationPair(MoneyValuePair)
    case transactionFiatRatePairs(TransactionMoneyValuePairs)
    case fatalTransactionError(Error)
    case validateTransaction
    case resetFlow
    case showSourceSelection
    case showTargetSelection
    case returnToPreviousStep
    case pendingTransactionStarted(allowFiatInput: Bool)
    case modifyTransactionConfirmation(TransactionConfirmation)
    case invalidateTransaction
}

extension TransactionAction {

    // TODO: Clean up this function
    // swiftlint:disable function_body_length
    // swiftlint:disable cyclomatic_complexity
    func reduce(oldState: TransactionState) -> TransactionState {
        Logger.shared.debug("[Transaction Flow] Readucing Action: \(self)")
        switch self {
        case .pendingTransactionStarted(let allowFiatInput):
            var newState = oldState
            newState.errorState = .none
            newState.allowFiatInput = allowFiatInput
            newState.nextEnabled = false
            return newState.withUpdatedBackstack(oldState: oldState)
        case .updateFeeLevelAndAmount:
            return oldState
        case .showBankLinkingFlow:
            var newState = oldState
            newState.step = .linkABank
            return newState.withUpdatedBackstack(oldState: oldState)
        case .bankAccountLinkedFromSource:
            var newState = oldState
            newState.step = .selectTarget
            return newState.withUpdatedBackstack(oldState: oldState)
        case .bankAccountLinked:
            var newState = oldState
            newState.step = .selectTarget
            return newState.withUpdatedBackstack(oldState: oldState)
        case .bankLinkingFlowDismissed(let action):
            var newState = oldState
            switch action {
            case .withdraw:
                newState.step = .selectTarget
            case .deposit:
                newState.step = .selectSource
            default:
                unimplemented()
            }
            return newState

        case .initialiseWithSourceAndTargetAccount(let action, let sourceAccount, let target, let passwordRequired):
            // If the user scans a BitPay QR code, the account will be a BitPayInvoiceTarget.
            // This means we do not proceed to the enter amount screen but rather the confirmation detail screen.
            let next: TransactionFlowStep = target is BitPayInvoiceTarget ? .confirmDetail : .enterAmount
            let step = passwordRequired ? .enterPassword : next
            return TransactionState(
                action: action,
                source: sourceAccount,
                destination: target,
                passwordRequired: passwordRequired,
                step: step
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithSourceAndPreferredTarget(let action, let sourceAccount, let target, let passwordRequired):
            return TransactionState(
                action: action,
                source: sourceAccount,
                destination: target,
                passwordRequired: passwordRequired,
                step: .enterAmount
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithTargetAndNoSource(let action, let target, let passwordRequired):
            // On buy the source is always the default payment method returned by the API
            // The source should be loaded based on this fact by the `TransactionModel` when processing the state change.
            return TransactionState(
                action: action,
                source: nil,
                destination: target,
                passwordRequired: passwordRequired,
                step: action == .buy ? .initial : .selectSource
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithNoSourceOrTargetAccount(let action, let passwordRequired):
            // On buy the source is always the default payment method returned by the API
            // The source should be loaded based on this fact by the `TransactionModel` when processing the state change.
            return TransactionState(
                action: action,
                passwordRequired: passwordRequired,
                step: action == .buy ? .initial : .selectSource
            )
            .withUpdatedBackstack(oldState: oldState)

        case .initialiseWithSourceAccount(let action, let sourceAccount, let passwordRequired):
            return TransactionState(
                action: action,
                source: sourceAccount,
                passwordRequired: passwordRequired
            )
        case .fetchFiatRates:
            return oldState
        case .fetchTargetRates:
            return oldState
        case .sourceDestinationPair(let pair):
            var newState = oldState
            newState.sourceDestinationPair = pair
            return newState
        case .transactionFiatRatePairs(let pair):
            var newState = oldState
            newState.destinationToFiatPair = pair.destination
            newState.sourceToFiatPair = pair.source
            return newState

        case .sourceAccountSelected(let sourceAccount):
            var newState = oldState
            newState.source = sourceAccount
            newState.sourceDestinationPair = nil
            newState.sourceToFiatPair = nil
            newState.destinationToFiatPair = nil

            // The standard flow is [select source] -> [select target] -> [enter amount] -> ...
            // Therefore if we have ... -> [enter amount] -> [select source] -> ... we should go back to [enter amount]
            let isGoingBack = newState.stepsBackStack.contains { $0 == .enterAmount }
            return newState
                .update(keyPath: \.isGoingBack, value: isGoingBack)
                .withUpdatedBackstack(oldState: oldState)

        case .targetAccountSelected(let destinationAccount):
            // If the user scans a BitPay QR code, the account will be a
            // BitPayInvoiceTarget. This means we do not proceed to the enter amount
            // screen but rather the confirmation detail screen.
            let step: TransactionFlowStep = destinationAccount is BitPayInvoiceTarget ? .confirmDetail : .enterAmount
            var newState = oldState
            newState.errorState = .none
            newState.destination = destinationAccount
            newState.nextEnabled = false
            newState.step = step
            newState.sourceDestinationPair = nil
            newState.sourceToFiatPair = nil
            newState.destinationToFiatPair = nil

            // The standard flow is [select source] -> [select target] -> [enter amount] -> ...
            // Therefore if we have ... -> [enter amount] -> [select target] -> ... we should go back to [enter amount]
            let isGoingBack = newState.stepsBackStack.contains { $0 == .enterAmount }
            return newState
                .update(keyPath: \.isGoingBack, value: isGoingBack)
                .withUpdatedBackstack(oldState: oldState)

        case .updateAmount:
            // Amount is updated after validation.
            var newState = oldState
            newState.nextEnabled = false
            return newState

        case .availableSourceAccountsListUpdated(let sources):
            var newState = oldState
            newState.availableSources = sources
            return newState.withUpdatedBackstack(oldState: oldState)

        case .availableDestinationAccountsListUpdated(let targets):
            let newStep: TransactionFlowStep
            if oldState.source != nil, oldState.destination != nil {
                // This operation could be done just to refresh the list of possible targets. E.g. for buy.
                // If we have both source and destination, the next step should be to enter an amount.
                newStep = oldState.passwordRequired ? .enterPassword : .enterAmount
            } else {
                // If there's not target account when this list is updated, we should have the user select one.
                newStep = oldState.passwordRequired ? .enterPassword : .selectTarget
            }
            return oldState
                .update(keyPath: \.availableTargets, value: targets as! [TransactionTarget])
                .update(keyPath: \.step, value: newStep)
                .update(keyPath: \.isGoingBack, value: false)
                .withUpdatedBackstack(oldState: oldState)

        case .pendingTransactionUpdated(let pendingTransaction):
            var newState = oldState
            newState.pendingTransaction = pendingTransaction
            newState.nextEnabled = pendingTransaction.validationState == .canExecute
            newState.errorState = pendingTransaction.validationState.mapToTransactionErrorState
            return newState.withUpdatedBackstack(oldState: oldState)

        case .showSourceSelection:
            return oldState
                .update(keyPath: \.step, value: .selectSource)
                .update(keyPath: \.isGoingBack, value: oldState.action != .buy)
                .withUpdatedBackstack(oldState: oldState)

        case .showTargetSelection:
            return oldState
                .update(keyPath: \.step, value: .selectTarget)
                .update(keyPath: \.isGoingBack, value: oldState.action != .buy)
                .withUpdatedBackstack(oldState: oldState)

        case .performKYCChecks:
            return oldState
                // KYC is shown and dismissed by a separate module so not for us to dismiss the modal
                .update(keyPath: \.step, value: .kycChecks)
                // Ensure this is threated as a step forward (although it won't be added to the back stack)
                .update(keyPath: \.isGoingBack, value: false)
                // Ensure the previoust step is in the back step
                .withUpdatedBackstack(oldState: oldState)

        case .prepareTransaction:
            var newState = oldState
            newState.nextEnabled = false // Don't enable until we get a validated pendingTx from the interactor
            newState.step = .confirmDetail
            return newState.withUpdatedBackstack(oldState: oldState)
        case .executeTransaction:
            var newState = oldState
            newState.nextEnabled = false
            newState.step = .inProgress
            newState.executionStatus = .inProgress
            return newState.withUpdatedBackstack(oldState: oldState)
        case .updateTransactionComplete:
            var newState = oldState
            newState.nextEnabled = true
            newState.executionStatus = .completed
            return newState.withUpdatedBackstack(oldState: oldState)
        case .fatalTransactionError(let error):
            Logger.shared.error(String(describing: error))
            var newState = oldState
            newState.nextEnabled = true
            newState.step = .inProgress
            newState.errorState = .fatalError(FatalTransactionError(error: error))
            newState.executionStatus = .error
            return newState.withUpdatedBackstack(oldState: oldState)
        case .validateTransaction:
            return oldState
        case .resetFlow:
            var newState = oldState
            newState.step = .closed
            return newState
        case .returnToPreviousStep:
            var stepsBackStack = oldState.stepsBackStack
            let previousStep = stepsBackStack.popLast() ?? .initial
            return oldState
                .update(keyPath: \.stepsBackStack, value: stepsBackStack)
                .update(keyPath: \.step, value: previousStep)
                .update(keyPath: \.isGoingBack, value: true)
                .update(keyPath: \.errorState, value: .none)
        case .modifyTransactionConfirmation:
            return oldState
        case .invalidateTransaction:
            return oldState
                .update(keyPath: \.pendingTransaction, value: nil)
                .update(keyPath: \.nextEnabled, value: false)
                .withUpdatedBackstack(oldState: oldState)
        }
    }

    // swiftlint:enable function_body_length
    // swiftlint:enable cyclomatic_complexity

    func isValid(for oldState: TransactionState) -> Bool {
        switch self {
        default:
            return true
        }
    }
}

enum FatalTransactionError: Error, Equatable {
    case rxError(RxError)
    case generic(Error)

    /// Initializes the enum with the given error, this check if it's an RxError and assigns correctly
    /// - Parameter error: An `Error` to be assigned
    init(error: Error) {
        guard let error = error as? RxError else {
            self = .generic(error)
            return
        }
        self = .rxError(error)
    }

    var rxError: RxError? {
        switch self {
        case .rxError(let error):
            return error
        case .generic:
            return nil
        }
    }

    var localizedDescription: String? {
        switch self {
        case .rxError(let error):
            return "\(LocalizationConstants.Errors.genericError) \n\(error.debugDescription)"
        case .generic(let error):
            return String(describing: error)
        }
    }

    static func == (lhs: FatalTransactionError, rhs: FatalTransactionError) -> Bool {
        switch (lhs, rhs) {
        case (.rxError(let left), .rxError(let right)):
            return left.debugDescription == right.localizedDescription
        case (.generic(let left), .generic(let right)):
            return left.localizedDescription == right.localizedDescription
        default:
            return false
        }
    }
}

extension TransactionState {

    func withUpdatedBackstack(oldState: TransactionState) -> TransactionState {
        if !isGoingBack, oldState.step != step, oldState.step.addToBackStack {
            var newState = self
            var newStack = oldState.stepsBackStack
            newStack.append(oldState.step)
            newState.stepsBackStack = newStack
            return newState
        }
        return self
    }
}

extension TransactionValidationState {
    var mapToTransactionErrorState: TransactionErrorState {
        switch self {
        case .addressIsContract:
            return .addressIsContract
        case .belowMinimumLimit:
            return .belowMinimumLimit
        case .canExecute:
            return .none
        case .insufficientFundsForFees:
            return .insufficientFundsForFees
        case .insufficientFunds:
            return .insufficientFunds
        case .insufficientGas:
            return .insufficientGas
        case .invalidAddress:
            return .invalidAddress
        case .invalidAmount:
            return .invalidAmount
        case .invoiceExpired:
            return .unknownError
        case .optionInvalid:
            return .optionInvalid
        case .overMaximumLimit:
            return .overMaximumLimit
        case .transactionInFlight:
            return .transactionInFlight
        case .uninitialized:
            return .none
        case .unknownError:
            return .unknownError
        case .overGoldTierLimit:
            return .overGoldTierLimit
        case .overSilverTierLimit:
            return .overSilverTierLimit
        case .pendingOrdersLimitReached:
            return .pendingOrdersLimitReached
        case .nabuError(let error):
            return .nabuError(error)
        }
    }
}
