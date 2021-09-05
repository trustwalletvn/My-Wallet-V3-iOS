// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DIKit
import FeatureAuthenticationDomain
import Localization
import ToolKit

// MARK: - Type

private typealias CredentialsLocalization = LocalizationConstants.CredentialsForm

public enum CredentialsAction: Equatable {
    public enum AlertAction: Equatable {
        case show(title: String, message: String)
        case dismiss
    }

    public enum WalletPairingAction: Equatable {
        case approveEmailAuthorization
        case needsEmailAuthorization
        case authenticate
        case authenticateWithTwoFAOrHardwareKey
        case decryptWalletWithPassword(String)
        case startPolling
        case pollWalletIdentifier
        case handleSMS
        case resendSMSCode
        case setupSessionToken
    }

    case continueButtonTapped
    case didAppear(context: CredentialsContext)
    case didChangeWalletIdentifier(String)
    case password(PasswordAction)
    case twoFA(TwoFAAction)
    case hardwareKey(HardwareKeyAction)
    case walletPairing(WalletPairingAction)
    case seedPhrase(SeedPhraseAction)
    case setTwoFAOrHardwareKeyVerified(Bool)
    case accountLockedErrorVisibility(Bool)
    case setTroubleLoggingInScreenVisible(Bool)
    case openExternalLink(URL)
    case alert(AlertAction)
    case closeButtonTapped
    case none
}

// MARK: - Properties

enum WalletPairingCancelations {
    struct WalletIdentifierPollingTimerId: Hashable {}
    struct WalletIdentifierPollingId: Hashable {}
}

public enum CredentialsContext: Equatable {
    case walletInfo(WalletInfo)
    case walletIdentifier(email: String)
    case manualPairing
    case none
}

struct CredentialsState: Equatable {
    var isTroubleLoggingInScreenVisible: Bool
    var passwordState: PasswordState
    var twoFAState: TwoFAState?
    var hardwareKeyState: HardwareKeyState?
    var seedPhraseState: SeedPhraseState?
    var emailAddress: String
    var walletGuid: String
    var emailCode: String
    var isTwoFACodeOrHardwareKeyVerified: Bool
    var isAccountLocked: Bool
    var isWalletIdentifierIncorrect: Bool
    var credentialsFailureAlert: AlertState<CredentialsAction>?
    var isManualPairing: Bool

    var isLoading: Bool

    init() {
        isTroubleLoggingInScreenVisible = false
        passwordState = .init()
        twoFAState = .init()
        hardwareKeyState = .init()
        seedPhraseState = .init()
        emailAddress = ""
        walletGuid = ""
        emailCode = ""
        isTwoFACodeOrHardwareKeyVerified = false
        isAccountLocked = false
        isWalletIdentifierIncorrect = false
        isLoading = false
        isManualPairing = false
    }
}

struct CredentialsEnvironment {
    typealias WalletValidation = (String) -> Bool

    let mainQueue: AnySchedulerOf<DispatchQueue>
    let pollingQueue: AnySchedulerOf<DispatchQueue>
    let sessionTokenService: SessionTokenServiceAPI
    let deviceVerificationService: DeviceVerificationServiceAPI
    let emailAuthorizationService: EmailAuthorizationServiceAPI
    let smsService: SMSServiceAPI
    let loginService: LoginServiceAPI
    let wallet: WalletFeatureAuthenticationDomainWrapper
    let analyticsRecorder: AnalyticsEventRecorderAPI
    let externalAppOpener: ExternalAppOpener
    let errorRecorder: ErrorRecording
    let walletIdentifierValidator: WalletValidation

    init(
        mainQueue: AnySchedulerOf<DispatchQueue> = .main,
        pollingQueue: AnySchedulerOf<DispatchQueue> = DispatchQueue(
            label: "com.blockchain.AuthenticationEnvironmentPollingQueue",
            qos: .utility
        ).eraseToAnyScheduler(),
        sessionTokenService: SessionTokenServiceAPI = resolve(),
        deviceVerificationService: DeviceVerificationServiceAPI,
        emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
        smsService: SMSServiceAPI = resolve(),
        loginService: LoginServiceAPI = resolve(),
        wallet: WalletFeatureAuthenticationDomainWrapper = resolve(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        externalAppOpener: ExternalAppOpener = resolve(),
        walletIdentifierValidator: @escaping WalletValidation = identifierValidator,
        errorRecorder: ErrorRecording
    ) {
        self.mainQueue = mainQueue
        self.pollingQueue = pollingQueue
        self.sessionTokenService = sessionTokenService
        self.deviceVerificationService = deviceVerificationService
        self.emailAuthorizationService = emailAuthorizationService
        self.smsService = smsService
        self.loginService = loginService
        self.wallet = wallet
        self.analyticsRecorder = analyticsRecorder
        self.externalAppOpener = externalAppOpener
        self.walletIdentifierValidator = walletIdentifierValidator
        self.errorRecorder = errorRecorder
    }
}

let credentialsReducer = Reducer.combine(
    passwordReducer
        .pullback(
            state: \CredentialsState.passwordState,
            action: /CredentialsAction.password,
            environment: { _ in PasswordEnvironment() }
        ),
    twoFAReducer
        .optional()
        .pullback(
            state: \CredentialsState.twoFAState,
            action: /CredentialsAction.twoFA,
            environment: { $0 }
        ),
    hardwareKeyReducer
        .optional()
        .pullback(
            state: \CredentialsState.hardwareKeyState,
            action: /CredentialsAction.hardwareKey,
            environment: { $0 }
        ),
    seedPhraseReducer
        .optional()
        .pullback(
            state: \CredentialsState.seedPhraseState,
            action: /CredentialsAction.seedPhrase,
            environment: { _ in SeedPhraseEnvironment() }
        ),
    Reducer<
        CredentialsState,
        CredentialsAction,
        CredentialsEnvironment
    > { state, action, environment in
        switch action {
        case .didAppear(.walletInfo(let info)):
            state.isTroubleLoggingInScreenVisible = false
            state.emailAddress = info.email
            state.walletGuid = info.guid
            state.emailCode = info.emailCode
            return .none

        case .didAppear(.walletIdentifier(let email)):
            state.isTroubleLoggingInScreenVisible = false
            state.emailAddress = email
            return .none

        case .didAppear(.manualPairing):
            state.isTroubleLoggingInScreenVisible = false
            state.emailAddress = "not available on manual pairing"
            state.isManualPairing = true
            return Effect(value: .walletPairing(.setupSessionToken))

        case .didAppear:
            return .none

        case .didChangeWalletIdentifier(let guid):
            state.walletGuid = guid
            guard !guid.isEmpty else {
                state.isWalletIdentifierIncorrect = false
                return .none
            }
            state.isWalletIdentifierIncorrect = !environment.walletIdentifierValidator(guid)
            return .none

        case .continueButtonTapped:
            guard let twoFAState = state.twoFAState,
                  let hardwareKeyState = state.hardwareKeyState
            else {
                fatalError("States should not be nil")
            }
            if twoFAState.isTwoFACodeFieldVisible ||
                hardwareKeyState.isHardwareKeyCodeFieldVisible
            {
                return Effect(value: .walletPairing(.authenticateWithTwoFAOrHardwareKey))
            }
            return Effect(value: .walletPairing(.authenticate))

        case .walletPairing(.approveEmailAuthorization):
            guard !state.emailCode.isEmpty else {
                // we still need to display an alert and poll here,
                // since we might end up here in case of a deeplink failure
                return .concatenate(
                    Effect(
                        value: .alert(
                            .show(
                                title: CredentialsLocalization.Alerts.EmailAuthorizationAlert.title,
                                message: CredentialsLocalization.Alerts.EmailAuthorizationAlert.message
                            )
                        )
                    ),
                    Effect(value: .walletPairing(.startPolling))
                )
            }
            return .merge(
                // Immediately authorize the email
                Effect(value: .walletPairing(.startPolling)),
                environment
                    .deviceVerificationService
                    .authorizeLogin(emailCode: state.emailCode)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        if case .failure(let error) = result {
                            // If failed, an `Authorize Log In` will be sent to user for manual authorization
                            environment.errorRecorder.error(error)
                            // we only want to handle `.expiredEmailCode` case, silent other errors...
                            guard error == .expiredEmailCode else {
                                return .none
                            }
                            return .alert(
                                .show(
                                    title: CredentialsLocalization.Alerts.EmailAuthorizationAlert.title,
                                    message: CredentialsLocalization.Alerts.EmailAuthorizationAlert.message
                                )
                            )
                        }
                        return .none
                    }
            )

        case .walletPairing(.startPolling):
            // Poll the Guid every 2 seconds
            return Effect
                .timer(
                    id: WalletPairingCancelations.WalletIdentifierPollingTimerId(),
                    every: 2,
                    on: environment.pollingQueue
                )
                .map { _ in .walletPairing(.pollWalletIdentifier) }

        case .walletPairing(.needsEmailAuthorization):
            return .concatenate(
                Effect(
                    value: .alert(
                        .show(
                            title: CredentialsLocalization.Alerts.EmailAuthorizationAlert.title,
                            message: CredentialsLocalization.Alerts.EmailAuthorizationAlert.message
                        )
                    )
                ),
                Effect(value: .walletPairing(.startPolling))
            )

        case .walletPairing(.authenticate):
            guard !state.walletGuid.isEmpty else {
                fatalError("GUID should not be empty")
            }
            guard let twoFAState = state.twoFAState,
                  let hardwareKeyState = state.hardwareKeyState
            else {
                fatalError("States should not be nil")
            }
            state.isLoading = true
            let password = state.passwordState.password
            let isManualPairing = state.isManualPairing
            return .merge(
                // Clear error states
                Effect(value: .accountLockedErrorVisibility(false)),
                Effect(value: .password(.incorrectPasswordErrorVisibility(false))),
                .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId()),
                environment
                    .loginService
                    .login(walletIdentifier: state.walletGuid)
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        switch result {
                        case .success:
                            return .walletPairing(.decryptWalletWithPassword(password))
                        case .failure(let error):
                            switch error {
                            case .twoFactorOTPRequired(let type):
                                switch type {
                                case .email:
                                    if isManualPairing {
                                        return .walletPairing(.needsEmailAuthorization)
                                    }
                                    return .walletPairing(.approveEmailAuthorization)
                                case .sms:
                                    return .walletPairing(.handleSMS)
                                case .google:
                                    return .twoFA(.twoFACodeFieldVisibility(true))
                                case .yubiKey, .yubikeyMtGox:
                                    return .hardwareKey(.hardwareKeyCodeFieldVisibility(true))
                                default:
                                    fatalError("Unsupported TwoFA Types")
                                }
                            case .walletPayloadServiceError(.accountLocked):
                                return .accountLockedErrorVisibility(true)
                            case .walletPayloadServiceError(let error):
                                environment.errorRecorder.error(error)
                                return .alert(
                                    .show(
                                        title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                                        message: CredentialsLocalization.Alerts.GenericNetworkError.message
                                    )
                                )
                            case .twoFAWalletServiceError:
                                fatalError("Shouldn't receive TwoFAService errors here")
                            }
                        }
                    }
            )

        case .walletPairing(.authenticateWithTwoFAOrHardwareKey):
            guard !state.walletGuid.isEmpty else {
                fatalError("GUID should not be empty")
            }
            guard let twoFAState = state.twoFAState,
                  let hardwareKeyState = state.hardwareKeyState
            else {
                fatalError("States should not be nil")
            }
            state.isLoading = true
            return .merge(
                // clear error states
                Effect(value: .hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(false))),
                Effect(value: .twoFA(.incorrectTwoFACodeErrorVisibility(.none))),
                environment
                    .loginService
                    .login(
                        walletIdentifier: state.walletGuid,
                        code: twoFAState.twoFACode
                    )
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .map { result -> CredentialsAction in
                        switch result {
                        case .success:
                            return .setTwoFAOrHardwareKeyVerified(true)
                        case .failure(let error):
                            switch error {
                            case .twoFAWalletServiceError(let error):
                                switch error {
                                case .wrongCode(let attemptsLeft):
                                    return .twoFA(.didChangeTwoFACodeAttemptsLeft(attemptsLeft))
                                case .accountLocked:
                                    return .accountLockedErrorVisibility(true)
                                case .missingCode:
                                    return .twoFA(.incorrectTwoFACodeErrorVisibility(.missingCode))
                                default:
                                    return .alert(
                                        .show(
                                            title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                                            message: CredentialsLocalization.Alerts.GenericNetworkError.message
                                        )
                                    )
                                }
                            case .walletPayloadServiceError:
                                fatalError("Shouldn't receive WalletPayloadService errors here")
                            case .twoFactorOTPRequired:
                                fatalError("Shouldn't receive twoFactorOTPRequired error here")
                            }
                        }
                    }
            )

        case .walletPairing(.decryptWalletWithPassword):
            // also handled in welcome reducer
            state.isLoading = true
            return .none

        case .walletPairing(.pollWalletIdentifier):
            return .concatenate(
                .cancel(id: WalletPairingCancelations.WalletIdentifierPollingId()),
                environment
                    .emailAuthorizationService
                    .authorizeEmailPublisher()
                    .receive(on: environment.mainQueue)
                    .catchToEffect()
                    .cancellable(id: WalletPairingCancelations.WalletIdentifierPollingId(), cancelInFlight: true)
                    .map { result -> CredentialsAction in
                        // Authenticate if the wallet identifier exists in repo
                        if case .success = result {
                            return .walletPairing(.authenticate)
                        }
                        return .none
                    }
            )

        case .walletPairing(.handleSMS):
            return .merge(
                Effect(value: .twoFA(.resendSMSButtonVisibility(true))),
                Effect(value: .twoFA(.twoFACodeFieldVisibility(true))),
                Effect(value: .alert(
                    .show(
                        title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                        message: CredentialsLocalization.Alerts.SMSCode.Success.message
                    )
                ))
            )

        case .walletPairing(.resendSMSCode):
            return environment
                .smsService
                .request()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> CredentialsAction in
                    if case .failure(let error) = result {
                        environment.errorRecorder.error(error)
                        return .alert(
                            .show(
                                title: CredentialsLocalization.Alerts.SMSCode.Failure.title,
                                message: CredentialsLocalization.Alerts.SMSCode.Failure.message
                            )
                        )
                    }
                    return .alert(
                        .show(
                            title: CredentialsLocalization.Alerts.SMSCode.Success.title,
                            message: CredentialsLocalization.Alerts.SMSCode.Success.message
                        )
                    )
                }

        case .walletPairing(.setupSessionToken):
            return environment
                .sessionTokenService
                .setupSessionToken()
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .map { result -> CredentialsAction in
                    if case .failure(let error) = result {
                        environment.errorRecorder.error(error)
                        return .alert(
                            .show(
                                title: CredentialsLocalization.Alerts.GenericNetworkError.title,
                                message: CredentialsLocalization.Alerts.GenericNetworkError.message
                            )
                        )
                    }
                    return .none
                }

        case .setTwoFAOrHardwareKeyVerified(let isVerified):
            state.isTwoFACodeOrHardwareKeyVerified = isVerified
            guard isVerified else {
                return .none
            }
            state.isLoading = false
            let password = state.passwordState.password
            return .merge(
                Effect(value: .walletPairing(.decryptWalletWithPassword(password)))
            )

        case .accountLockedErrorVisibility(let isVisible):
            state.isAccountLocked = isVisible
            state.isLoading = isVisible ? false : state.isLoading
            return .none

        case .openExternalLink(let url):
            environment.externalAppOpener.open(url)
            return .none

        case .alert(.show(let title, let message)):
            state.isLoading = false
            state.credentialsFailureAlert = AlertState(
                title: TextState(verbatim: title),
                message: TextState(verbatim: message),
                dismissButton: .default(
                    TextState(LocalizationConstants.okString),
                    action: .send(.alert(.dismiss))
                )
            )
            return .none

        case .alert(.dismiss):
            state.credentialsFailureAlert = nil
            return .none

        case .twoFA(.twoFACodeFieldVisibility(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none
        case .twoFA(.incorrectTwoFACodeErrorVisibility(let context)):
            state.isLoading = context.hasError ? false : state.isLoading
            return .none
        case .hardwareKey(.hardwareKeyCodeFieldVisibility(let visible)),
             .hardwareKey(.incorrectHardwareKeyCodeErrorVisibility(let visible)):
            state.isLoading = visible ? false : state.isLoading
            return .none

        case .password(.incorrectPasswordErrorVisibility(true)):
            state.isLoading = false
            // reset state
            state.twoFAState = .init()
            state.hardwareKeyState = .init()
            return .none
        case .password(.incorrectPasswordErrorVisibility(false)):
            state.isLoading = true
            return .none

        case .setTroubleLoggingInScreenVisible(let visible):
            state.isTroubleLoggingInScreenVisible = visible
            return .none

        case .twoFA:
            return .none
        case .hardwareKey:
            return .none
        case .password:
            return .none
        case .seedPhrase:
            return .none
        case .closeButtonTapped:
            return .cancel(id: WalletPairingCancelations.WalletIdentifierPollingTimerId())
        case .none:
            return .none
        }
    }
)
.analytics()

// MARK: - Private

private func identifierValidator(_ value: String) -> Bool {
    value.range(of: TextRegex.walletIdentifier.rawValue, options: .regularExpression) != nil
}

extension Reducer where
    Action == CredentialsAction,
    State == CredentialsState,
    Environment == CredentialsEnvironment
{
    /// Helper reducer for analytics tracking
    fileprivate func analytics() -> Self {
        combined(
            with: Reducer<
                CredentialsState,
                CredentialsAction,
                CredentialsEnvironment
            > { _, action, environment in
                switch action {
                case .continueButtonTapped:
                    environment.analyticsRecorder.record(
                        event: .loginPasswordEntered
                    )
                    return .none
                case .walletPairing(.authenticateWithTwoFAOrHardwareKey):
                    environment.analyticsRecorder.record(
                        event: .loginTwoStepVerificationEntered
                    )
                    return .none
                case .twoFA(.didChangeTwoFACodeAttemptsLeft):
                    environment.analyticsRecorder.record(
                        event: .loginTwoStepVerificationDenied
                    )
                    return .none
                default:
                    return .none
                }
            }
        )
    }
}
