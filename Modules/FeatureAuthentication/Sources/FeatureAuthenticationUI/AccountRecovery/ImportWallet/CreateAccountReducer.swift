// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import ToolKit

// MARK: - Type

enum CreateAccountAction: Equatable {
    case didDisappear
    case didChangeEmailAddress(String)
    case didChangePassword(String)
    case didChangeConfirmPassword(String)
    case didChangePasswordStrength(PasswordValidationScore)
    case validatePasswordStrength
    case openExternalLink(URL)
    case none
}

// MARK: - Properties

struct CreateAccountState: Equatable {
    var emailAddress: String
    var password: String
    var confirmPassword: String
    var passwordStrength: PasswordValidationScore

    init() {
        emailAddress = ""
        password = ""
        confirmPassword = ""
        passwordStrength = .none
    }
}

struct CreateAccountEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let passwordValidator: PasswordValidatorAPI
    let externalAppOpener: ExternalAppOpener

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        passwordValidator: PasswordValidatorAPI = PasswordValidator(),
        externalAppOpener: ExternalAppOpener = resolve()
    ) {
        self.mainQueue = mainQueue
        self.passwordValidator = passwordValidator
        self.externalAppOpener = externalAppOpener
    }
}

let createAccountReducer = Reducer<
    CreateAccountState,
    CreateAccountAction,
    CreateAccountEnvironment
> { state, action, environment in
    switch action {
    case .didDisappear:
        state.emailAddress = ""
        state.password = ""
        state.confirmPassword = ""
        return .none
    case .didChangeEmailAddress(let emailAddress):
        state.emailAddress = emailAddress
        return .none
    case .didChangePassword(let password):
        state.password = password
        return .none
    case .didChangeConfirmPassword(let password):
        state.confirmPassword = password
        return .none
    case .didChangePasswordStrength(let score):
        state.passwordStrength = score
        return .none
    case .validatePasswordStrength:
        return environment
            .passwordValidator
            .validate(password: state.password)
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .map { result -> CreateAccountAction in
                guard case .success(let score) = result else {
                    return .none
                }
                return .didChangePasswordStrength(score)
            }
    case .openExternalLink(let url):
        environment.externalAppOpener.open(url)
        return .none
    case .none:
        return .none
    }
}
