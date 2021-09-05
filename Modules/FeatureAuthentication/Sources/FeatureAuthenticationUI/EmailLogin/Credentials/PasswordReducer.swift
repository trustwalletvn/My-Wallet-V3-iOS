// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum PasswordAction: Equatable {
    case didChangePassword(String)
    case didChangeFocusedState(Bool)
    case incorrectPasswordErrorVisibility(Bool)
}

// MARK: - Properties

struct PasswordState: Equatable {
    var password: String
    var isFocused: Bool
    var isPasswordIncorrect: Bool

    var isValid: Bool {
        !isPasswordIncorrect && !password.isEmpty
    }

    init() {
        password = ""
        isFocused = false
        isPasswordIncorrect = false
    }
}

struct PasswordEnvironment {}

let passwordReducer = Reducer<
    PasswordState,
    PasswordAction,
    PasswordEnvironment
> { state, action, _ in
    switch action {
    case .didChangePassword(let password):
        state.isPasswordIncorrect = false
        state.password = password
        return .none
    case .didChangeFocusedState(let isFocused):
        state.isFocused = isFocused
        return .none
    case .incorrectPasswordErrorVisibility(let isVisible):
        state.isPasswordIncorrect = isVisible
        return .none
    }
}
