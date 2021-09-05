// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum HardwareKeyAction: Equatable {
    case didChangeHardwareKeyCode(String)
    case didChangeFocusedState(Bool)
    case hardwareKeyCodeFieldVisibility(Bool)
    case incorrectHardwareKeyCodeErrorVisibility(Bool)
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
    case .hardwareKeyCodeFieldVisibility(let isVisible):
        state.hardwareKeyCode = ""
        state.isHardwareKeyCodeFieldVisible = isVisible
        return .none
    case .incorrectHardwareKeyCodeErrorVisibility(let isVisible):
        state.isHardwareKeyCodeIncorrect = isVisible
        return .none
    }
}
