// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum SeedPhraseAction: Equatable {
    case didChangeSeedPhrase(String)
    case didChangeSeedPhraseScore(MnemonicValidationScore)
    case validateSeedPhrase
    case setResetPasswordScreenVisible(Bool)
    case resetPassword(ResetPasswordAction)
    case none
}

enum AccountRecoveryContext: Equatable {
    case troubleLoggingIn
    case importWallet
    case none
}

// MARK: - Properties

struct SeedPhraseState: Equatable {
    var seedPhrase: String
    var seedPhraseScore: MnemonicValidationScore
    var isResetPasswordScreenVisible: Bool
    var resetPasswordState: ResetPasswordState?

    init() {
        seedPhrase = ""
        seedPhraseScore = .none
        isResetPasswordScreenVisible = false
    }
}

struct SeedPhraseEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validator: SeedPhraseValidatorAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        validator: SeedPhraseValidatorAPI = SeedPhraseValidator()
    ) {
        self.mainQueue = mainQueue
        self.validator = validator
    }
}

let seedPhraseReducer = Reducer.combine(
    resetPasswordReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetPasswordState,
            action: /SeedPhraseAction.resetPassword,
            environment: { _ in ResetPasswordEnvironment() }
        ),
    Reducer<
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseEnvironment
    > { state, action, environment in
        switch action {
        case .didChangeSeedPhrase(let seedPhrase):
            state.seedPhrase = seedPhrase
            return .none
        case .didChangeSeedPhraseScore(let score):
            state.seedPhraseScore = score
            return .none
        case .validateSeedPhrase:
            return environment
                .validator
                .validate(phrase: state.seedPhrase)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> SeedPhraseAction in
                    guard case .success(let score) = result else {
                        return .none
                    }
                    return .didChangeSeedPhraseScore(score)
                }
        case .setResetPasswordScreenVisible(let isVisible):
            state.isResetPasswordScreenVisible = isVisible
            if isVisible {
                state.resetPasswordState = .init()
            }
            return .none
        case .resetPassword:
            // handled in reset password reducer
            return .none
        case .none:
            return .none
        }
    }
)
