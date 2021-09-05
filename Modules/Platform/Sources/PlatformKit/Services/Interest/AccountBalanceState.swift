// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum AccountBalanceState<Value: Equatable>: Equatable {
    case absent
    case present(Value)

    public var balance: Value? {
        switch self {
        case .absent:
            return nil
        case .present(let balance):
            return balance
        }
    }
}
