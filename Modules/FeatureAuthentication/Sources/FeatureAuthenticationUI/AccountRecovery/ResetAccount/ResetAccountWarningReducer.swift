// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum ResetAccountWarningAction: Equatable {
    case retryButtonTapped
    case continueResetButtonTapped
}

struct ResetAccountWarningState: Equatable {}

struct ResetAccountWarningEnvironment {}

let resetAccountWarningReducer = Reducer<
    ResetAccountWarningState,
    ResetAccountWarningAction,
    ResetAccountWarningEnvironment
> { _, action, _ in
    switch action {
    case .retryButtonTapped:
        return .none
    case .continueResetButtonTapped:
        return .none
    }
}
