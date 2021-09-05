// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift
import ToolKit

/// The view model for wallet pairing screen
final class ManualPairingScreenPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Onboarding.ManualPairingScreen

    // MARK: - Properties

    let navBarStyle = Screen.Style.Bar.lightContent()
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let walletIdTextFieldViewModel: TextFieldViewModel
    let passwordTextFieldViewModel: TextFieldViewModel
    let buttonViewModel = ButtonViewModel.primary(
        with: LocalizedString.button
    )

    /// The total state of the presentation
    var state: Driver<FormPresentationState> {
        stateRelay.asDriver()
    }

    /// Relay to the next route
    let nextRouteRelay = PublishRelay<Void>()

    // MARK: - Injected

    private let interactor: ManualPairingInteractor
    private unowned let routerStateProvider: OnboardingRouterStateProviding
    private let alertPresenter: AlertViewPresenter
    private let emailAuthorizationPresenter: EmailAuthorizationPresenter
    private let loadingViewPresenter: LoadingViewPresenting

    // MARK: - Accessors

    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        interactor: ManualPairingInteractor = ManualPairingInteractor(),
        routerStateProvider: OnboardingRouterStateProviding = resolve(),
        alertPresenter: AlertViewPresenter = .shared,
        loadingViewPresenter: LoadingViewPresenting = resolve()
    ) {
        self.routerStateProvider = routerStateProvider
        self.alertPresenter = alertPresenter
        self.loadingViewPresenter = loadingViewPresenter
        self.interactor = interactor
        emailAuthorizationPresenter = EmailAuthorizationPresenter()
        walletIdTextFieldViewModel = TextFieldViewModel(
            with: .walletIdentifier,
            validator: TextValidationFactory.Info.walletIdentifier,
            messageRecorder: CrashlyticsRecorder()
        )
        passwordTextFieldViewModel = TextFieldViewModel(
            with: .password,
            validator: TextValidationFactory.Password.login,
            messageRecorder: CrashlyticsRecorder()
        )

        let latestStatesObservable = Observable
            .combineLatest(
                walletIdTextFieldViewModel.state,
                passwordTextFieldViewModel.state
            )

        let stateObservable = latestStatesObservable
            .map(weak: self) { (self, payload) -> FormPresentationState in
                try self.stateReducer.reduce(states: [payload.0, payload.1])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchErrorJustReturn(.invalid(.invalidTextField))
            .share(replay: 1)

        /// Bind the state
        stateObservable
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        /// Controls button `isEnabled` property
        stateObservable
            .map(\.isValid)
            .bindAndCatch(to: buttonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        // Extract the latest valid values to the interaction layer
        latestStatesObservable
            .compactMap { walletIdState, passwordState -> ManualPairingInteractor.Content? in
                guard let walletId = walletIdState.value, let password = passwordState.value else { return nil }
                return .init(walletIdentifier: walletId, password: password)
            }
            .bindAndCatch(to: interactor.contentStateRelay)
            .disposed(by: disposeBag)

        buttonViewModel.tapRelay
            .bind { [unowned self] in
                self.pair(using: .standard)
            }
            .disposed(by: disposeBag)

        /// Bind authentication action
        interactor.authenticationAction
            .hide(loader: loadingViewPresenter)
            .observeOn(MainScheduler.instance)
            .bind { [weak self] action in
                guard let self = self else { return }
                switch action {
                case .authorizeLoginWithEmail:
                    self.displayEmailAuthorizationAlert()
                case .authorizeLoginWith2FA(let type):
                    self.display2FAAlert(
                        title: LocalizedString.TwoFAAlert.title,
                        message: String(
                            format: LocalizedString.TwoFAAlert.message,
                            type.name
                        ),
                        type: type
                    )
                case .wrongOtpCode(type: let type, attemptsLeft: let attemptsLeft):
                    self.display2FAAlert(
                        title: LocalizedString.TwoFAAlert.wrongCodeTitle,
                        message: String(
                            format: LocalizedString.TwoFAAlert.wrongCodeMessage,
                            attemptsLeft,
                            type.name
                        ),
                        type: type
                    )
                case .lockedAccount:
                    self.displayLockedAccountAlert()
                case .message(let string):
                    self.alertPresenter.standardError(message: string)
                case .error(let error):
                    self.alertPresenter.standardError(message: String(describing: error))
                }
            }
            .disposed(by: disposeBag)
    }

    // MARK: - Lifecycle

    func viewDidLoad() {
        walletIdTextFieldViewModel.focusRelay.accept(.on)
    }

    func viewDidDisappear() {
        emailAuthorizationPresenter.cancel()
        routerStateProvider.state = .standard
    }

    // MARK: - Accessors

    private func pair(using type: ManualPairingInteractor.AuthenticationType) {
        routerStateProvider.state = .standard
        loadingViewPresenter.showCircular(
            with: LocalizationConstants.Authentication.loadingWallet
        )
        do {
            try interactor.pair(using: type)
        } catch { // TODO: Handle additional errors
            alertPresenter.internetConnection()
            loadingViewPresenter.hide()
        }
    }

    /// Requests an OTP by SMS
    private func requestOTPMessage(title: String, message: String, type: WalletAuthenticatorType) {
        display2FAAlert(title: title, message: message, type: type)
        interactor.requestOTPMessage()
            .subscribe(
                onError: { [weak alertPresenter] _ in
                    guard let alertPresenter = alertPresenter else { return }
                    alertPresenter.standardNotify(
                        title: LocalizedString.RequestOtpMessageErrorAlert.title,
                        message: LocalizedString.RequestOtpMessageErrorAlert.message
                    )
                }
            )
            .disposed(by: disposeBag)
    }

    /// Displays an alert asking the user for second OTP using one
    /// of the supported `AuthenticatorType` values
    private func display2FAAlert(title: String, message: String, type: WalletAuthenticatorType) {
        routerStateProvider.state = .pending2FA

        let cancel = { [weak self] () -> Void in
            self?.routerStateProvider.state = .standard
        }

        alertPresenter.dismissIfNeeded { [weak self] in
            guard let self = self else { return }
            var resend: (() -> Void)?
            if type == .sms {
                resend = {
                    self.requestOTPMessage(
                        title: title,
                        message: message,
                        type: type
                    )
                }
            }
            self.alertPresenter.notify2FA(
                type: type,
                title: title,
                message: message,
                resendAction: resend,
                cancel: cancel
            ) { otp in
                self.pair(using: .twoFA(otp))
            }
        }
    }

    /// Displays an alert asking the user for authorizing the login
    /// on his email
    private func displayEmailAuthorizationAlert() {
        // This method is designed to fail silently
        emailAuthorizationPresenter.authorize()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak self] in
                    self?.pair(using: .standard)
                },
                // The error event is designed to be handled silently
                onError: { error in
                    Logger.shared.error(error)
                }
            )
            .disposed(by: disposeBag)
    }

    /// Displays an alert that informs that user that his account is locked
    private func displayLockedAccountAlert() {
        alertPresenter.dismissIfNeeded { [weak self] in
            guard let self = self else { return }
            self.alertPresenter.notify(
                content: .init(
                    title: LocalizedString.AccountLockedAlert.title,
                    message: LocalizedString.AccountLockedAlert.message
                )
            )
        }
    }
}

/// NOTE: This is here rather than in `PlatformKit` to prevent having to add
/// `Localization.framework` as a dependency for `PlatformKit`
extension WalletAuthenticatorType {
    fileprivate var name: String {
        switch self {
        case .google:
            return LocalizationConstants.AuthType.google
        case .yubiKey:
            return LocalizationConstants.AuthType.yubiKey
        case .sms:
            return LocalizationConstants.AuthType.sms
        case .standard:
            return ""
        default: // Other are unsupported
            return ""
        }
    }
}
