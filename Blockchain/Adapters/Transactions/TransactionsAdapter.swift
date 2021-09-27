// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionUI
import PlatformKit

/// Represents all types of transactions the user can perform.
enum TransactionType: Equatable {

    /// Performs a buy. If `CrytoAccount` is `nil`, the users will be presented with a crypto currency selector.
    case buy(CryptoAccount?)
    /// Performs a sell. If `CrytoCurrency` is `nil`, the users will be presented with a crypto currency selector.
    case sell(CryptoAccount?)

    static func == (lhs: TransactionType, rhs: TransactionType) -> Bool {
        switch (lhs, rhs) {
        case (.buy(let lhsAccount), .buy(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        case (.sell(let lhsAccount), .sell(let rhsAccount)):
            return lhsAccount?.identifier == rhsAccount?.identifier
        default:
            return false
        }
    }
}

/// Represents the possible outcomes of going through the transaction flow.
enum TransactionResult: Equatable {
    case abandoned
    case completed
}

/// A protocol defining the API for the app's entry point to any `Transaction Flow`. The app should only use this interface to let users perform any kind of transaction.
/// NOTE: Presenting a Transaction Flow can never fail because it's expected for any error to be handled within the flow. Non-recoverable errors should force the user to abandon the flow.
protocol TransactionsAdapterAPI {

    /// Presents a Transactions Flow for the passed-in type of transaction to perform using the `presenter` as a starting point.
    /// - Parameters:
    ///   - transactionToPerform: The desireed type of transaction to be performed.
    ///   - presenter: The `ViewController` used to present the Transaction Flow.
    ///   - completion: A closure called when the user has completed or abandoned the Transaction Flow.
    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController,
        completion: @escaping (TransactionResult) -> Void
    )

    /// Presents a Transactions Flow for the passed-in type of transaction to perform using the `presenter` as a starting point.
    /// - Parameters:
    ///   - transactionToPerform: The desireed type of transaction to be performed.
    ///   - presenter: The `ViewController` used to present the Transaction Flow.
    /// - Returns: A `Combine.Publisher` that publishes a `TransactionResult` once and never fails.
    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionResult, Never>
}

// MARK: - Interface Implementation

extension TransactionType {

    fileprivate var transactionFlowActionValue: TransactionFlowAction {
        switch self {
        case .buy(let cryptoCurrency):
            return .buy(cryptoCurrency)
        case .sell(let cryptoCurrency):
            return .sell(cryptoCurrency)
        }
    }
}

extension TransactionResult {

    fileprivate init(_ transactionFlowResult: TransactionFlowResult) {
        switch transactionFlowResult {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

final class TransactionsAdapter: TransactionsAdapterAPI {

    private let router: FeatureTransactionUI.TransactionsRouterAPI
    private var cancellables = Set<AnyCancellable>()

    init(router: FeatureTransactionUI.TransactionsRouterAPI = resolve()) {
        self.router = router
    }

    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController,
        completion: @escaping (TransactionResult) -> Void
    ) {
        presentTransactionFlow(to: transactionToPerform, from: presenter)
            .sink(receiveValue: completion)
            .store(in: &cancellables)
    }

    func presentTransactionFlow(
        to transactionToPerform: TransactionType,
        from presenter: UIViewController
    ) -> AnyPublisher<TransactionResult, Never> {
        router.presentTransactionFlow(to: transactionToPerform.transactionFlowActionValue, from: presenter)
            .map(TransactionResult.init)
            .eraseToAnyPublisher()
    }
}
