// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import PlatformUIKit
import RxSwift

/// Types adopting `SourceAndTargetAccountProviding` should provide access to the source and destination account
public protocol SourceAndTargetAccountProviding: AccountPickerAccountProviding {
    var sourceAccount: Single<BlockchainAccount?> { get }
    var destinationAccount: Observable<TransactionTarget?> { get }
}

class TransactionModelAccountProvider: SourceAndTargetAccountProviding {

    private let transactionModel: TransactionModel

    var accounts: Observable<[BlockchainAccount]> {
        transactionModel
            .state
            .map(transform)
            .distinctUntilChanged { lhs, rhs in
                lhs.map(\.identifier) == rhs.map(\.identifier)
            }
    }

    var sourceAccount: Single<BlockchainAccount?> {
        transactionModel.state
            .map(\.source)
            .take(1)
            .asSingle()
    }

    var destinationAccount: Observable<TransactionTarget?> {
        transactionModel.state
            .map(\.destination)
    }

    private let transform: (TransactionState) -> [BlockchainAccount]

    /// TransactionModelAccountProvider
    ///
    /// - parameter transactionModel: An `TransactionModel` which `state` will be observed.
    /// - parameter transform: A transform function to apply to each source element of `TransactionModel.state`.
    init(
        transactionModel: TransactionModel,
        transform: @escaping (TransactionState) -> [BlockchainAccount]
    ) {
        self.transactionModel = transactionModel
        self.transform = transform
    }
}
