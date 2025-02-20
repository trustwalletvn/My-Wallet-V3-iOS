// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public final class TransactionProcessor {

    // MARK: - Public properties

    public var canTransactFiat: Bool {
        engine.canTransactFiat
    }

    public var fiatExchangeRatePairs: Observable<TransactionMoneyValuePairs> {
        engine.fiatExchangeRatePairs
    }

    // If the source and target assets are not the same this MAY return a stream of the exchange rates
    // between them. Or it may simply complete.
    public var transactionExchangeRatePair: Observable<MoneyValuePair> {
        engine.transactionExchangeRatePair
    }

    // Initialise the transaction as required.
    // This will start propagating the pendingTx to the client code.
    public var initializeTransaction: Observable<PendingTransaction> {
        engine
            .initializeTransaction()
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asObservable()
            .flatMap(weak: self) { (self, _) -> Observable<PendingTransaction> in
                self.pendingTxSubject
            }
    }

    // MARK: - Private properties

    private let engine: TransactionEngine
    private let pendingTxSubject: BehaviorSubject<PendingTransaction>
    private let disposeBag = DisposeBag()

    // MARK: - Init

    init(
        sourceAccount: BlockchainAccount,
        transactionTarget: TransactionTarget,
        engine: TransactionEngine
    ) {
        self.engine = engine
        pendingTxSubject = BehaviorSubject(value: .zero(currencyType: sourceAccount.currencyType))
        engine.start(
            sourceAccount: sourceAccount,
            transactionTarget: transactionTarget,
            askForRefreshConfirmation: { [weak self] revalidate in
                guard let self = self else {
                    return .empty()
                }
                return self.refreshConfirmations(revalidate: revalidate)
            }
        )
        engine.assertInputsValid()
    }

    // MARK: - Public methods

    public func reset() {
        do {
            engine.stop(pendingTransaction: try pendingTransaction())
        } catch {}
    }

    // Set the option to the passed option value. If the option is not supported, it will not be
    // in the original list when the pendingTx is created. And if it is not supported, then trying to
    // update it will cause an error.
    public func set(transactionConfirmation: TransactionConfirmation) -> Completable {
        Logger.shared.debug("!TRANSACTION!> in `set(transactionConfirmation): \(transactionConfirmation)`")
        do {
            let pendingTx = try pendingTransaction()
            if !pendingTx.confirmations.contains(where: { $0.bareCompare(to: transactionConfirmation) }) {
                let error = PlatformKitError.illegalStateException(
                    message: "Unsupported TransactionConfirmation: \(transactionConfirmation)"
                )
                return .just(event: .error(error))
            }
            return engine
                .doOptionUpdateRequest(
                    pendingTransaction: pendingTx,
                    newConfirmation: transactionConfirmation
                )
                .flatMap(weak: self) { (self, transaction) -> Single<PendingTransaction> in
                    self.engine.doValidateAll(pendingTransaction: transaction)
                }
                .do(onSuccess: { [weak self] transaction in
                    guard let self = self else { return }
                    self.updatePendingTx(transaction)
                })
                .asObservable()
                .ignoreElements()
        } catch {
            return .just(event: .error(error))
        }
    }

    public func updateAmount(amount: MoneyValue) -> Completable {
        Logger.shared.debug("!TRANSACTION!> in `updateAmount: \(amount.displayString)`")
        do {
            if !canTransactFiat, amount.isFiat {
                throw PlatformKitError.illegalStateException(
                    message: "Engine.canTransactFiat \(canTransactFiat) but amount.isFiat: \(amount.isFiat)"
                )
            }
            return engine
                .update(amount: amount, pendingTransaction: try pendingTransaction())
                .flatMap(weak: self) { (self, transaction) -> Single<PendingTransaction> in
                    let isFreshTx = transaction.validationState == .uninitialized
                    return self.engine
                        .validateAmount(pendingTransaction: transaction)
                        .map { transaction -> PendingTransaction in
                            // Remove initial "insufficient funds' warning
                            if transaction.amount.isZero, isFreshTx {
                                var newTx = transaction
                                newTx.validationState = .uninitialized
                                return newTx
                            } else {
                                return transaction
                            }
                        }
                }
                .do(onSuccess: { [weak self] pendingTransaction in
                    self?.updatePendingTx(pendingTransaction)
                })
                .asCompletable()
        } catch {
            return .just(event: .error(error))
        }
    }

    public func execute(secondPassword: String) -> Single<TransactionResult> {
        Logger.shared.debug("!TRANSACTION!> in `execute`")
        do {
            if engine.requireSecondPassword, secondPassword.isEmpty {
                throw PlatformKitError.illegalStateException(message: "Second password not supplied")
            }
            let pendingTransaction = try self.pendingTransaction()
            return engine
                .doValidateAll(pendingTransaction: pendingTransaction)
                .do(onSuccess: { transaction in
                    guard transaction.validationState == .canExecute else {
                        throw PlatformKitError.illegalStateException(message: "PendingTx is not executable")
                    }
                })
                .flatMap(weak: self) { (self, transaction) -> Single<TransactionResult> in
                    self.engine.execute(pendingTransaction: transaction, secondPassword: secondPassword)
                }
        } catch {
            return .error(error)
        }
    }

    public func validateAll() -> Completable {
        Logger.shared.debug("!TRANSACTION!> in `validateAll`")
        guard let pendingTransaction = try? self.pendingTransaction() else {
            preconditionFailure("We should always have a pending transaction when validating")
        }
        return engine.doBuildConfirmations(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.engine.doValidateAll(pendingTransaction: pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                self.engine.startConfirmationsUpdate(pendingTransaction: pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asCompletable()
    }

    /// Check that the fee level is supported,
    /// then call into the engine to set the fee and validate ballances etc
    public func updateFeeLevel(_ feeLevel: FeeLevel, customFeeAmount: MoneyValue?) -> Completable {
        Logger.shared.debug("!TRANSACTION!> in `UpdateFeeLevel`")
        guard let pendingTransaction = try? self.pendingTransaction() else {
            preconditionFailure("We should always have a pending transaction when validating")
        }
        precondition(pendingTransaction.feeSelection.availableLevels.contains(feeLevel))
        return engine
            .doUpdateFeeLevel(
                pendingTransaction: pendingTransaction,
                level: feeLevel,
                customFeeAmount: customFeeAmount ?? .zero(currency: pendingTransaction.amount.currency)
            )
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asCompletable()
    }

    // MARK: - Private methods

    // Called back by the engine if it has received an external signal and the existing confirmation set
    // requires a refresh
    private func refreshConfirmations(revalidate: Bool) -> Completable {
        Logger.shared.debug("!TRANSACTION!> in `refreshConfirmations`")
        guard let pendingTransaction = try? self.pendingTransaction() else {
            return .empty() // TODO: or error?
        }
        guard !pendingTransaction.confirmations.isEmpty else {
            return .empty()
        }
        return engine.doRefreshConfirmations(pendingTransaction: pendingTransaction)
            .flatMap(weak: self) { (self, pendingTransaction) -> Single<PendingTransaction> in
                if revalidate {
                    return self.engine.doValidateAll(pendingTransaction: pendingTransaction)
                }
                return .just(pendingTransaction)
            }
            .do(onSuccess: { [weak self] pendingTransaction in
                self?.updatePendingTx(pendingTransaction)
            })
            .asCompletable()
    }

    private func pendingTransaction() throws -> PendingTransaction {
        try pendingTxSubject.value()
    }

    private func updatePendingTx(_ transaction: PendingTransaction) {
        pendingTxSubject.on(.next(transaction))
    }
}
