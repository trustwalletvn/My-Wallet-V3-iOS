// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

private typealias EmailLoginLocalization = LocalizationConstants.EmailLogin

public enum EmailLoginAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case closeButtonTapped
    case onAppear
    case didChangeEmailAddress(String)
    case didSendDeviceVerificationEmail(Result<EmptyValue, DeviceVerificationServiceError>)
    case alert(AlertAction)
    case setupSessionToken
    case sendDeviceVerificationEmail
    case setVerifyDeviceScreenVisible(Bool)
    case verifyDevice(VerifyDeviceAction)
    case none
}

// MARK: - Properties

struct EmailLoginState: Equatable {
    var emailAddress: String
    var isEmailValid: Bool
    var isVerifyDeviceScreenVisible: Bool
    var verifyDeviceState: VerifyDeviceState?
    var emailLoginFailureAlert: AlertState<EmailLoginAction>?
    var isLoading: Bool

    init() {
        verifyDeviceState = nil
        emailAddress = ""
        isEmailValid = false
        isVerifyDeviceScreenVisible = false
        isLoading = false
    }
}

struct EmailLoginEnvironment {
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let errorRecorder: ErrorRecording
    let validateEmail: (String) -> Bool
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        sessionTokenService: SessionTokenServiceAPI,
        deviceVerificationService: DeviceVerificationServiceAPI,
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        errorRecorder: ErrorRecording,
        analyticsRecorder: AnalyticsEventRecorderAPI,
        validateEmail: @escaping (String) -> Bool = { $0.isEmail }
    ) {
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.mainQueue = mainQueue
        self.errorRecorder = errorRecorder
        self.analyticsRecorder = analyticsRecorder
        self.validateEmail = validateEmail
    }
}

let emailLoginReducer = Reducer.combine(
    verifyDeviceReducer
        .optional()
        .pullback(
            state: \.verifyDeviceState,
            action: /EmailLoginAction.verifyDevice,
            environment: {
                VerifyDeviceEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService
                )
            }
        ),
    Reducer<
        EmailLoginState,
        EmailLoginAction,
        EmailLoginEnvironment
    > { state, action, environment in
        switch action {
        case .closeButtonTapped:
            // handled in welcome reducer
            return .none

        case .onAppear:
            environment.analyticsRecorder.record(
                event: .loginViewed
            )
            return Effect(value: .setupSessionToken)

        case .didChangeEmailAddress(let emailAddress):
            state.emailAddress = emailAddress
            state.isEmailValid = environment.validateEmail(emailAddress)
            return .none

        case .didSendDeviceVerificationEmail(let response):
            state.isLoading = false
            state.verifyDeviceState?.sendEmailButtonIsLoading = false
            if case .failure(let error) = response {
                switch error {
                case .recaptchaError,
                     .missingSessionToken:
                    return Effect(
                        value: .alert(
                            .show(
                                title: EmailLoginLocalization.Alerts.SignInError.title,
                                message: EmailLoginLocalization.Alerts.SignInError.message
                            )
                        )
                    )
                case .networkError,
                     .expiredEmailCode:
                    // still go to verify device screen if there is network error
                    break
                }
            }
            return Effect(value: .setVerifyDeviceScreenVisible(true))

        case .alert(.show(let title, let message)):
            state.emailLoginFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.continueString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.emailLoginFailureAlert = nil
            return .none

        case .setupSessionToken:
            return environment
                .sessionTokenService
                .setupSessionToken()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> EmailLoginAction in
                    if case .failure(let error) = result {
                        environment.errorRecorder.error(error)
                        return .alert(
                            .show(
                                title: EmailLoginLocalization.Alerts.GenericNetworkError.title,
                                message: EmailLoginLocalization.Alerts.GenericNetworkError.message
                            )
                        )
                    }
                    return .none
                }

        case .sendDeviceVerificationEmail,
             .verifyDevice(.sendDeviceVerificationEmail):
            guard state.isEmailValid else {
                return .none
            }
            state.isLoading = true
            state.verifyDeviceState?.sendEmailButtonIsLoading = true
            return environment
                .deviceVerificationService
                .sendDeviceVerificationEmail(to: state.emailAddress)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> EmailLoginAction in
                    switch result {
                    case .success:
                        return .didSendDeviceVerificationEmail(.success(.noValue))
                    case .failure(let error):
                        return .didSendDeviceVerificationEmail(.failure(error))
                    }
                }

        case .setVerifyDeviceScreenVisible(let isVisible):
            state.isVerifyDeviceScreenVisible = isVisible
            if isVisible {
                state.verifyDeviceState = .init(emailAddress: state.emailAddress)
            }
            return .none

        case .verifyDevice:
            // handled in verify device reducer
            return .none

        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == EmailLoginAction,
    State == EmailLoginState,
    Environment == EmailLoginEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                EmailLoginState,
                EmailLoginAction,
                EmailLoginEnvironment
            > { _, action, environment in
                switch action {
                case .sendDeviceVerificationEmail:
                    environment.analyticsRecorder.record(
                        event: .loginClicked(
                            origin: .navigation
                        )
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
