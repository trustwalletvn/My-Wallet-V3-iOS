// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum LostFundsWarningAction: Equatable {
    case resetAccountButtonTapped
    case goBackButtonTapped
}

struct LostFundsWarningState: Equatable {}

struct LostFundsWarningEnvironment {}

let lostFundsWarningReducer = Reducer<
    LostFundsWarningState,
    LostFundsWarningAction,
    LostFundsWarningEnvironment
> { _, action, _ in
    switch action {
    case .goBackButtonTapped:
        return .none
    case .resetAccountButtonTapped:
        return .none
    }
}
