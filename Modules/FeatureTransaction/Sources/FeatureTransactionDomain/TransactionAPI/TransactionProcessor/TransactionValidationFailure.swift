// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct TransactionValidationFailure: Error {
    public let state: TransactionValidationState

    public init(state: TransactionValidationState) {
        self.state = state
    }
}
