// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

struct UnlockTradingState: Equatable {
    let viewModel: UnlockTradingViewModel
}

enum UnlockTradingAction: Equatable {
    case closeButtonTapped
    case unlockButtonTapped
}

struct UnlockTradingEnvironment {
    let dismiss: () -> Void
    let unlock: () -> Void
}

let unlockTradingReducer = Reducer<
    UnlockTradingState,
    UnlockTradingAction,
    UnlockTradingEnvironment
> { _, action, environment in
    switch action {
    case .closeButtonTapped:
        environment.dismiss()

    case .unlockButtonTapped:
        environment.unlock()
    }
    return .none
}
