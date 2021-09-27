// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum HardwareKeyAction: Equatable {
    case didChangeHardwareKeyCode(String)
    case didChangeFocusedState(Bool)
    case showHardwareKeyCodeField(Bool)
    case showIncorrectHardwareKeyCodeError(Bool)
}

// MARK: - Properties

struct HardwareKeyState: Equatable {
    var hardwareKeyCode: String = ""
    var isFocused: Bool = false
    var isHardwareKeyCodeFieldVisible = false
    var isHardwareKeyCodeIncorrect: Bool = false
}

let hardwareKeyReducer = Reducer<
    HardwareKeyState,
    HardwareKeyAction,
    CredentialsEnvironment
> {
    state, action, _ in
    switch action {
    case .didChangeHardwareKeyCode(let code):
        state.hardwareKeyCode = code
        return .none
    case .didChangeFocusedState(let isFocused):
        state.isFocused = isFocused
        return .none
    case .showHardwareKeyCodeField(let shouldShow):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = shouldShow
        return .none
    case .showIncorrectHardwareKeyCodeError(let shouldShow):
        state.isHardwareKeyCodeIncorrect = shouldShow
        return .none
    }
}
