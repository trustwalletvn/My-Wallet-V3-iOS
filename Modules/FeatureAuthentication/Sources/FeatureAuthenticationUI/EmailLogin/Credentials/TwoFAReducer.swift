// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

// MARK: - Type

public enum TwoFAAction: Equatable {
    public enum IncorrectTwoFAContext: Equatable {
        case incorrect
        case missingCode
        case none

        var hasError: Bool {
            self != .none
        }
    }

    case didChangeTwoFACode(String)
    case didChangeTwoFACodeAttemptsLeft(Int)
    case showIncorrectTwoFACodeError(IncorrectTwoFAContext)
    case showResendSMSButton(Bool)
    case showTwoFACodeField(Bool)
}

private enum Constants {
    static let twoFACodeMaxAttemptsLeft = 5
}

// MARK: - Properties

struct TwoFAState: Equatable {
    var twoFACode: String
    var isTwoFACodeFieldVisible: Bool
    var isResendSMSButtonVisible: Bool
    var isTwoFACodeIncorrect: Bool
    var twoFACodeIncorrectContext: TwoFAAction.IncorrectTwoFAContext
    var twoFACodeAttemptsLeft: Int

    init() {
        twoFACode = ""
        isTwoFACodeFieldVisible = false
        isResendSMSButtonVisible = false
        isTwoFACodeIncorrect = false
        twoFACodeAttemptsLeft = Constants.twoFACodeMaxAttemptsLeft
        twoFACodeIncorrectContext = .none
    }
}

let twoFAReducer = Reducer<
    TwoFAState,
    TwoFAAction,
    CredentialsEnvironment
> { state, action, _ in
    switch action {
    case .didChangeTwoFACode(let code):
        state.twoFACode = code
        return .none
    case .didChangeTwoFACodeAttemptsLeft(let attemptsLeft):
        state.twoFACodeAttemptsLeft = attemptsLeft
        return Effect(value: .showIncorrectTwoFACodeError(.incorrect))
    case .showIncorrectTwoFACodeError(let context):
        state.twoFACodeIncorrectContext = context
        state.isTwoFACodeIncorrect = context.hasError
        return .none
    case .showResendSMSButton(let shouldShow):
        state.isResendSMSButtonVisible = shouldShow
        return .none
    case .showTwoFACodeField(let isVisible):
        state.twoFACode = ""
        state.isTwoFACodeFieldVisible = isVisible
        return .none
    }
}
