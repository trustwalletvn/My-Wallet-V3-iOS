// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

public enum SeedPhraseAction: Equatable {
    case closeButtonTapped
    case didChangeSeedPhrase(String)
    case didChangeSeedPhraseScore(MnemonicValidationScore)
    case validateSeedPhrase
    case setResetPasswordScreenVisible(Bool)
    case setResetAccountBottomSheetVisible(Bool)
    case setLostFundsWarningScreenVisible(Bool)
    case setImportWalletScreenVisible(Bool)
    case resetPassword(ResetPasswordAction)
    case resetAccountWarning(ResetAccountWarningAction)
    case lostFundsWarning(LostFundsWarningAction)
    case importWallet(ImportWalletAction)
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
    var isResetAccountBottomSheetVisible: Bool
    var isLostFundsWarningScreenVisible: Bool
    var isImportWalletScreenVisible: Bool
    var resetPasswordState: ResetPasswordState?
    var resetAccountWarningState: ResetAccountWarningState?
    var lostFundsWarningState: LostFundsWarningState?
    var importWalletState: ImportWalletState?

    init() {
        seedPhrase = ""
        seedPhraseScore = .none
        isResetPasswordScreenVisible = false
        isResetAccountBottomSheetVisible = false
        isLostFundsWarningScreenVisible = false
        isImportWalletScreenVisible = false
    }
}

struct SeedPhraseEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let validator: SeedPhraseValidatorAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue>,
        validator: SeedPhraseValidatorAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.validator = validator
    }
}

let seedPhraseReducer = Reducer.combine(
    importWalletReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.importWalletState,
            action: /SeedPhraseAction.importWallet,
            environment: { _ in ImportWalletEnvironment() }
        ),
    resetAccountWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetAccountWarningState,
            action: /SeedPhraseAction.resetAccountWarning,
            environment: { _ in ResetAccountWarningEnvironment() }
        ),
    lostFundsWarningReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.lostFundsWarningState,
            action: /SeedPhraseAction.lostFundsWarning,
            environment: { _ in LostFundsWarningEnvironment() }
        ),
    resetPasswordReducer
        .optional()
        .pullback(
            state: \SeedPhraseState.resetPasswordState,
            action: /SeedPhraseAction.resetPassword,
            environment: {
                ResetPasswordEnvironment(
                    mainQueue: $0.mainQueue
                )
            }
        ),
    Reducer<
        SeedPhraseState,
        SeedPhraseAction,
        SeedPhraseEnvironment
    > { state, action, environment in
        switch action {
        case .closeButtonTapped:
            return .none
        case .didChangeSeedPhrase(let seedPhrase):
            state.seedPhrase = seedPhrase
            return Effect(value: .validateSeedPhrase)
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
        case .setResetAccountBottomSheetVisible(let isVisible):
            state.isResetAccountBottomSheetVisible = isVisible
            if isVisible {
                state.resetAccountWarningState = .init()
            }
            return .none
        case .setLostFundsWarningScreenVisible(let isVisible):
            state.isLostFundsWarningScreenVisible = isVisible
            if isVisible {
                state.lostFundsWarningState = .init()
            }
            return .none
        case .setImportWalletScreenVisible(let isVisible):
            state.isImportWalletScreenVisible = isVisible
            if isVisible {
                state.importWalletState = .init()
            }
            return .none
        case .resetPassword:
            // handled in reset password reducer
            return .none
        case .resetAccountWarning(.retryButtonTapped):
            return Effect(value: .setResetAccountBottomSheetVisible(false))
        case .resetAccountWarning(.continueResetButtonTapped):
            return .merge(
                Effect(value: .setResetAccountBottomSheetVisible(false)),
                Effect(value: .setLostFundsWarningScreenVisible(true))
            )
        case .lostFundsWarning(.goBackButtonTapped):
            return Effect(value: .setLostFundsWarningScreenVisible(false))
        case .lostFundsWarning(.resetAccountButtonTapped):
            return Effect(value: .setResetPasswordScreenVisible(true))
        case .importWallet(.goBackButtonTapped):
            return Effect(value: .setImportWalletScreenVisible(false))
        case .importWallet(.importWalletButtonTapped):
            return .none
        case .importWallet:
            return .none
        case .none:
            return .none
        }
    }
)
