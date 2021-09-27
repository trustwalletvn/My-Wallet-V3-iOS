// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture

public enum ImportWalletAction: Equatable {
    case importWalletButtonTapped
    case goBackButtonTapped
    case setCreateAccountScreenVisible(Bool)
    case createAccount(CreateAccountAction)
}

struct ImportWalletState: Equatable {
    var createAccountState: CreateAccountState?
    var isCreateAccountScreenVisible: Bool

    init() {
        isCreateAccountScreenVisible = false
    }
}

struct ImportWalletEnvironment: Equatable {}

let importWalletReducer = Reducer.combine(
    createAccountReducer
        .optional()
        .pullback(
            state: \.createAccountState,
            action: /ImportWalletAction.createAccount,
            environment: { _ in CreateAccountEnvironment() }
        ),
    Reducer<
        ImportWalletState,
        ImportWalletAction,
        ImportWalletEnvironment
    > { state, action, _ in
        switch action {
        case .setCreateAccountScreenVisible(let isVisible):
            state.isCreateAccountScreenVisible = isVisible
            if isVisible {
                state.createAccountState = .init()
            }
            return .none
        case .importWalletButtonTapped:
            return .none
        case .goBackButtonTapped:
            return .none
        case .createAccount:
            return .none
        }
    }
)
