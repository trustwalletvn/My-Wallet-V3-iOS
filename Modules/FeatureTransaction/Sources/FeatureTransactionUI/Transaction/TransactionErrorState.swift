// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

enum TransactionErrorState: Equatable {
    case none
    case addressIsContract
    case belowMinimumLimit
    case insufficientFunds
    case insufficientGas
    case insufficientFundsForFees
    case invalidAddress
    case invalidAmount
    case invalidPassword
    case optionInvalid
    case overGoldTierLimit
    case overMaximumLimit
    case overSilverTierLimit
    case pendingOrdersLimitReached
    case transactionInFlight
    case unknownError
    case fatalError(FatalTransactionError)
    case nabuError(NabuError)
}

extension TransactionErrorState {
    var fatalError: FatalTransactionError? {
        switch self {
        case .fatalError(let error):
            return error
        default:
            return nil
        }
    }
}
