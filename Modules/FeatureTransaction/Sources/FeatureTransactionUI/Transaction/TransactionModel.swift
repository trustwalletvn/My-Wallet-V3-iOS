// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureTransactionDomain
import PlatformKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

final class TransactionModel {

    // MARK: - Private Properties

    private var mviModel: MviModel<TransactionState, TransactionAction>!
    private let interactor: TransactionInteractor
    private var hasInitializedTransaction: Bool = false

    // MARK: - Public Properties

    var state: Observable<TransactionState> {
        mviModel.state
    }

    // MARK: - Init

    init(initialState: TransactionState, transactionInteractor: TransactionInteractor) {
        interactor = transactionInteractor
        mviModel = MviModel(
            initialState: initialState,
            performAction: { [weak self] state, action -> Disposable? in
                self?.perform(previousState: state, action: action)
            }
        )
    }

    // MARK: - Internal methods

    func process(action: TransactionAction) {
        mviModel.process(action: action)
    }

    func perform(previousState: TransactionState, action: TransactionAction) -> Disposable? {
        Logger.shared.debug("[Transaction Flow] Perform action: \(action) on state:")
        switch action {
        case .pendingTransactionStarted:
            return nil
        case .initialiseWithSourceAndTargetAccount(let action, let sourceAccount, let target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: .zero(currency: sourceAccount.currencyType),
                action: action
            )
        case .initialiseWithSourceAndPreferredTarget(let action, let sourceAccount, let target, _):
            return processTargetSelectionConfirmed(
                sourceAccount: sourceAccount,
                transactionTarget: target,
                amount: .zero(currency: sourceAccount.currencyType),
                action: action
            )
        case .initialiseWithTargetAndNoSource(let action, _, _),
             .initialiseWithNoSourceOrTargetAccount(let action, _):
            return processSourceAccountsListUpdate(action: action)

        case .availableSourceAccountsListUpdated:
            return nil

        case .availableDestinationAccountsListUpdated:
            return processAvailableDestinationAccountsListUpdated(state: previousState)

        case .bankAccountLinked(let action):
            return processSourceAccountsListUpdate(action: action)
        case .bankAccountLinkedFromSource(let source, let action):
            return processTargetAccountsListUpdate(fromAccount: source, action: action)
        case .showBankLinkingFlow,
             .bankLinkingFlowDismissed:
            return nil
        case .initialiseWithSourceAccount(let action, let sourceAccount, _):
            return processTargetAccountsListUpdate(fromAccount: sourceAccount, action: action)
        case .targetAccountSelected(let destinationAccount):
            guard let source = previousState.source else {
                fatalError("You should have a sourceAccount.")
            }
            let sourceCurrency = source.currencyType
            let isAmountValid = previousState.amount.currencyType == sourceCurrency
            let amount = isAmountValid ? previousState.amount : .zero(currency: sourceCurrency)
            // If the `amount` `currencyType` differs from the source, we should
            // use `zero` as the amount. If not, it is safe to use the
            // `previousState.amount`.
            // The `amount` should always be the same `currencyType` as the `source`.
            return processTargetSelectionConfirmed(
                sourceAccount: source,
                transactionTarget: destinationAccount,
                amount: amount,
                action: previousState.action
            )
        case .updateAmount(let amount):
            return processAmountChanged(amount: amount)
        case .updateFeeLevelAndAmount(let feeLevel, let amount):
            return processSetFeeLevel(feeLevel, amount: amount)
        case .pendingTransactionUpdated:
            return nil
        case .performKYCChecks:
            return nil
        case .prepareTransaction:
            return nil
        case .executeTransaction:
            return processExecuteTransaction(secondPassword: previousState.secondPassword)
        case .updateTransactionComplete:
            return nil
        case .fetchFiatRates:
            return processFiatRatePairs()
        case .fetchTargetRates:
            return processTransactionRatePair()
        case .transactionFiatRatePairs:
            return nil
        case .sourceDestinationPair:
            return nil
        case .fatalTransactionError:
            return nil
        case .validateTransaction:
            return processValidateTransaction()
        case .resetFlow:
            interactor.reset()
            return nil
        case .returnToPreviousStep:
            let isBitPay = previousState.step == .confirmDetail && previousState.destination is BitPayInvoiceTarget
            let isAmountScreen = previousState.step == .enterAmount
            guard isAmountScreen || isBitPay else {
                return nil
            }
            return processTransactionInvalidation(action: previousState.action)
        case .sourceAccountSelected(let sourceAccount):
            if let target = previousState.destination, !previousState.availableTargets.isEmpty {
                // The user has already selected a destination such as through `Deposit`. In this case we want to
                // go straight to the Enter Amount screen, since we have both target and source.
                return processTargetSelectionConfirmed(
                    sourceAccount: sourceAccount,
                    transactionTarget: target,
                    amount: .zero(currency: sourceAccount.currencyType),
                    action: previousState.action
                )
            }
            // If the user still has to select a destination or a list of possible destinations is not available, that's the next step.
            return processTargetAccountsListUpdate(
                fromAccount: sourceAccount,
                action: previousState.action
            )
        case .modifyTransactionConfirmation(let confirmation):
            return processModifyTransactionConfirmation(confirmation: confirmation)
        case .invalidateTransaction:
            return processInvalidateTransaction()
        case .showSourceSelection:
            return nil
        case .showTargetSelection:
            return nil
        }
    }

    func destroy() {
        mviModel.destroy()
    }

    // MARK: - Private methods

    private func processModifyTransactionConfirmation(confirmation: TransactionConfirmation) -> Disposable {
        interactor
            .modifyTransactionConfirmation(confirmation)
            .subscribe(
                onError: { error in
                    // swiftlint:disable:next line_length
                    Logger.shared.error("!TRANSACTION!> Unable to modify transaction confirmation: \(String(describing: error))")
                }
            )
    }

    private func processSetFeeLevel(_ feeLevel: FeeLevel, amount: MoneyValue?) -> Disposable {
        interactor.updateTransactionFees(with: feeLevel, amount: amount)
            .subscribe(onCompleted: {
                Logger.shared.debug("!TRANSACTION!> Tx setFeeLevel complete")
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to set feeLevel: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processSourceAccountsListUpdate(action: AssetAction) -> Disposable {
        interactor.getAvailableSourceAccounts(action: action)
            .subscribe(
                onSuccess: { [weak self] sourceAccounts in
                    self?.process(action: .availableSourceAccountsListUpdated(sourceAccounts))
                    if action == .buy, let first = sourceAccounts.first {
                        // For buy, we don't want to display the list of possible sources straight away.
                        // Instead, we want to select the default payment method returned by the API.
                        // Therefore, once we know what payment methods the user has avaialble, we should select the top one.
                        // This assumes that the API or the Service used for it sorts the payment methods so the default one is the first.
                        self?.process(action: .sourceAccountSelected(first))
                    }
                },
                onError: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to get source accounts: \(String(describing: error))")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }

    private func processValidateTransaction() -> Disposable {
        interactor.validateTransaction
            .subscribe(onCompleted: {
                Logger.shared.debug("!TRANSACTION!> Tx validation complete")
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to processValidateTransaction: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processExecuteTransaction(secondPassword: String) -> Disposable {
        interactor.verifyAndExecute(secondPassword: secondPassword)
            .subscribe(onSuccess: { [weak self] result in
                self?.process(action: .updateTransactionComplete(result))
            }, onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to processExecuteTransaction: \(String(describing: error))")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processAmountChanged(amount: MoneyValue) -> Disposable? {
        guard hasInitializedTransaction else {
            return nil
        }
        return interactor.update(amount: amount)
            .subscribe(onError: { [weak self] error in
                Logger.shared.error("!TRANSACTION!> Unable to process amount: \(error)")
                self?.process(action: .fatalTransactionError(error))
            })
    }

    private func processTargetSelectionConfirmed(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        amount: MoneyValue,
        action: AssetAction
    ) -> Disposable {
        // since we have both source and destination we can simply initialize a `PendingTransaction`
        initializeTransaction(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            amount: amount,
            action: action
        )
    }

    // At this point we can build a transactor object from coincore and configure
    // the state object a bit more; depending on whether it's an internal, external,
    // bitpay or BTC Url address we can set things like note, amount, fee schedule
    // and hook up the correct processor to execute the transaction.
    private func initializeTransaction(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        amount: MoneyValue,
        action: AssetAction
    ) -> Disposable {
        hasInitializedTransaction = false
        return interactor
            .initializeTransaction(sourceAccount: sourceAccount, transactionTarget: transactionTarget, action: action)
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                guard !self.hasInitializedTransaction else { return }
                self.hasInitializedTransaction.toggle()
                self.onFirstUpdate(amount: amount)
            })
            .subscribe(
                onNext: { [weak self] transaction in
                    self?.process(action: .pendingTransactionUpdated(transaction))
                },
                onError: { [weak self] error in
                    Logger.shared.error("!TRANSACTION!> Unable to initialize transaction: \(String(describing: error))")
                    self?.process(action: .fatalTransactionError(error))
                }
            )
    }

    private func onFirstUpdate(amount: MoneyValue) {
        process(action: .pendingTransactionStarted(allowFiatInput: interactor.canTransactFiat))
        process(action: .fetchFiatRates)
        process(action: .fetchTargetRates)
        process(action: .updateAmount(amount))
    }

    private func processTargetAccountsListUpdate(fromAccount: BlockchainAccount, action: AssetAction) -> Disposable {
        interactor
            .getTargetAccounts(sourceAccount: fromAccount, action: action)
            .subscribe { [weak self] accounts in
                self?.process(action: .availableDestinationAccountsListUpdated(accounts))
            }
    }

    private func processFiatRatePairs() -> Disposable {
        interactor
            .startFiatRatePairsFetch
            .subscribe { [weak self] transactionMoneyValuePairs in
                self?.process(action: .transactionFiatRatePairs(transactionMoneyValuePairs))
            }
    }

    private func processTransactionRatePair() -> Disposable {
        interactor
            .startCryptoRatePairFetch
            .subscribe { [weak self] moneyValuePair in
                self?.process(action: .sourceDestinationPair(moneyValuePair))
            }
    }

    private func processTransactionInvalidation(action: AssetAction) -> Disposable {
        Observable.just(())
            .subscribe(onNext: { [weak self] _ in
                self?.process(action: .invalidateTransaction)
            })
    }

    private func processInvalidateTransaction() -> Disposable {
        interactor.invalidateTransaction()
            .subscribe()
    }

    private func processAvailableDestinationAccountsListUpdated(state: TransactionState) -> Disposable? {
        if let destination = state.destination {
            // If we refreshed the list of possible accounts we need to proceed to enter amount
            // That said, the current implementation doesn't initialize a `PendingTransaction` until
            // a target is selected. A target was already selected in this case, but the exchange rate data
            // was not updated. Triggering this action will refresh the transaction and make it load.
            // NOTE: This may not be the best approach, but it's the same used in `sourceAccountSelected` for deposit.
            // NOTE: Trying another approach like loading the fiat rates causes a crash as the transaction is not yet properly initialized.
            return Observable.just(())
                .subscribe(onNext: { [weak self] in
                    self?.process(action: .targetAccountSelected(destination))
                })
        }
        return nil
    }
}
