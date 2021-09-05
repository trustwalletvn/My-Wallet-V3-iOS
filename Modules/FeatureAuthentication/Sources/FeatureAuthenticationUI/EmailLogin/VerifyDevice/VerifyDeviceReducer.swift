// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

public enum VerifyDeviceAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    case credentials(CredentialsAction)
    case didAppear
    case fallbackToWalletIdentifier
    case didExtractWalletInfo(WalletInfo)
    case didReceiveWalletInfoDeeplink(URL)
    case sendDeviceVerificationEmail
    case openMailApp
    case setCredentialsScreenVisible(Bool)
    case verifyDeviceFailureAlert(AlertAction)
    case none
}

// MARK: - Properties

struct VerifyDeviceState: Equatable {
    var isCredentialsScreenVisible: Bool
    var credentialsContext: CredentialsContext
    var credentialsState: CredentialsState?
    var verifyDeviceFailureAlert: AlertState<VerifyDeviceAction>?
    var emailAddress: String
    var sendEmailButtonIsLoading: Bool

    init(emailAddress: String) {
        self.emailAddress = emailAddress
        credentialsState = nil
        isCredentialsScreenVisible = false
        credentialsContext = .none
        sendEmailButtonIsLoading = false
    }
}

struct VerifyDeviceEnvironment {
    let mainQueue: AnySchedulerOf<DispatchQueue>
    let deviceVerificationService: DeviceVerificationServiceAPI
    let errorRecorder: ErrorRecording
    let externalAppOpener: ExternalAppOpener
    let analyticsRecorder: AnalyticsEventRecorderAPI

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        deviceVerificationService: DeviceVerificationServiceAPI,
        errorRecorder: ErrorRecording = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve()
    ) {
        self.mainQueue = mainQueue
        self.deviceVerificationService = deviceVerificationService
        self.errorRecorder = errorRecorder
        self.externalAppOpener = externalAppOpener
        self.analyticsRecorder = analyticsRecorder
    }
}

let verifyDeviceReducer = Reducer.combine(
    credentialsReducer
        .optional()
        .pullback(
            state: \.credentialsState,
            action: /VerifyDeviceAction.credentials,
            environment: {
                CredentialsEnvironment(
                    mainQueue: $0.mainQueue,
                    deviceVerificationService: $0.deviceVerificationService,
                    errorRecorder: $0.errorRecorder
                )
            }
        ),
    Reducer<
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    > { state, action, environment in
        switch action {
        case .didAppear:
            // making sure credentials view is not immediately pushed when going to verify device view
            state.isCredentialsScreenVisible = false
            return .none

        case .credentials:
            // handled in credentials reducer
            return .none

        case .didExtractWalletInfo(let walletInfo):
            state.credentialsContext = .walletInfo(walletInfo)
            return Effect(value: .setCredentialsScreenVisible(true))

        case .fallbackToWalletIdentifier:
            state.credentialsContext = .walletIdentifier(email: state.emailAddress)
            return Effect(value: .setCredentialsScreenVisible(true))

        case .didReceiveWalletInfoDeeplink(let url):
            return environment
                .deviceVerificationService
                .extractWalletInfoFromDeeplink(url: url)
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> VerifyDeviceAction in
                    switch result {
                    case .success(let walletInfo):
                        return .didExtractWalletInfo(walletInfo)
                    case .failure(let error):
                        environment.errorRecorder.error(error)
                        return .fallbackToWalletIdentifier
                    }
                }

        case .sendDeviceVerificationEmail:
            // handled in email login reducer
            return .none

        case .openMailApp:
            environment
                .externalAppOpener
                .openMailApp { _ in }
            return .none

        case .setCredentialsScreenVisible(let isVisible):
            state.isCredentialsScreenVisible = isVisible
            if isVisible {
                state.credentialsState = .init()
            }
            return .none

        case .verifyDeviceFailureAlert(.show(let title, let message)):
            state.verifyDeviceFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.verifyDeviceFailureAlert(.dismiss))
                )
            )
            return .none

        case .verifyDeviceFailureAlert(.dismiss):
            state.verifyDeviceFailureAlert = nil
            return .none
        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Private

extension Reducer where
    Action == VerifyDeviceAction,
    State == VerifyDeviceState,
    Environment == VerifyDeviceEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                VerifyDeviceState,
                VerifyDeviceAction,
                VerifyDeviceEnvironment
            > { _, action, environment in
                switch action {
                case .didExtractWalletInfo(let walletInfo):
                    environment.analyticsRecorder.record(
                        event: .deviceVerified(info: walletInfo)
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
