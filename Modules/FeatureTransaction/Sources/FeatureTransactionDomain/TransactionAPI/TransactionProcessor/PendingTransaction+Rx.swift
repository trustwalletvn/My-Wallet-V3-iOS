// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

extension Completable {

    public func updateTxValidityCompletable(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        flatMapSingle { () -> Single<PendingTransaction> in
            .just(pendingTransaction.update(validationState: .canExecute))
        }
        .updateTxValiditySingle(pendingTransaction: pendingTransaction)
    }
}

extension PrimitiveSequence where Trait == SingleTrait, Element == PendingTransaction {

    func updateTxValiditySingle(pendingTransaction: PendingTransaction) -> Single<PendingTransaction> {
        catchError { error -> Single<PendingTransaction> in
            guard let validationError = error as? TransactionValidationFailure else {
                throw error
            }
            return .just(pendingTransaction.update(validationState: validationError.state))
        }
        .map { pendingTransaction -> PendingTransaction in
            if pendingTransaction.confirmations.isEmpty {
                return pendingTransaction
            } else {
                return updateOptionsWithValidityWarning(pendingTransaction: pendingTransaction)
            }
        }
    }

    private func updateOptionsWithValidityWarning(pendingTransaction: PendingTransaction) -> PendingTransaction {
        switch pendingTransaction.validationState {
        case .canExecute,
             .uninitialized:
            return pendingTransaction.remove(optionType: .errorNotice)
        default:
            let error = TransactionConfirmation.Model.ErrorNotice(
                validationState: pendingTransaction.validationState,
                moneyValue: pendingTransaction.validationState == .belowMinimumLimit ? pendingTransaction.minimumLimit : nil
            )
            return pendingTransaction.insert(confirmation: .errorNotice(error))
        }
    }
}
