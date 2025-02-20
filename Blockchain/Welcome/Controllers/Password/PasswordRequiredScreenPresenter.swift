// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import PlatformUIKit
import RxCocoa
import RxRelay
import RxSwift

final class PasswordRequiredScreenPresenter {

    /// Typealias to lessen verbosity
    private typealias LocalizedString = LocalizationConstants.Onboarding.PasswordRequiredScreen

    // MARK: - Exposed Properties

    let navBarStyle = Screen.Style.Bar.lightContent()
    let titleStyle = Screen.Style.TitleView.text(value: LocalizedString.title)
    let description = LocalizedString.description
    let forgetDescription = LocalizedString.forgetWalletDescription
    let passwordTextFieldViewModel = TextFieldViewModel(
        with: .password,
        validator: TextValidationFactory.Password.login,
        messageRecorder: CrashlyticsRecorder()
    )
    let continueButtonViewModel = ButtonViewModel.primary(
        with: LocalizedString.continueButton
    )
    let forgotPasswordButtonViewModel = ButtonViewModel.secondary(
        with: LocalizedString.forgotButton
    )

    let forgetWalletButtonViewModel = ButtonViewModel.destructive(
        with: LocalizedString.forgetWalletButton
    )

    /// The total state of the presentation
    var state: Driver<FormPresentationState> {
        stateRelay.asDriver()
    }

    // MARK: - Injected

    private let loadingViewPresenter: LoadingViewPresenting
    private let launchAnnouncementPresenter: LaunchAnnouncementPresenter
    private let interactor: PasswordRequiredScreenInteractor
    private let alertPresenter: AlertViewPresenter
    private let forgetWalletRouting: (() -> Void)?

    // MARK: - Private Properties

    private let stateReducer = FormPresentationStateReducer()
    private let stateRelay = BehaviorRelay<FormPresentationState>(value: .invalid(.emptyTextField))

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(
        interactor: PasswordRequiredScreenInteractor,
        forgetWalletRouting: (() -> Void)?,
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        launchAnnouncementPresenter: LaunchAnnouncementPresenter = LaunchAnnouncementPresenter(),
        alertPresenter: AlertViewPresenter = .shared
    ) {
        self.loadingViewPresenter = loadingViewPresenter
        self.launchAnnouncementPresenter = launchAnnouncementPresenter
        self.alertPresenter = alertPresenter
        self.interactor = interactor
        self.forgetWalletRouting = forgetWalletRouting

        let stateObservable = passwordTextFieldViewModel.state
            .map(weak: self) { (self, payload) -> FormPresentationState in
                try self.stateReducer.reduce(states: [payload])
            }
            /// Should never get to `catchErrorJustReturn`.
            .catchErrorJustReturn(.invalid(.invalidTextField))
            .share(replay: 1)

        stateObservable
            .bindAndCatch(to: stateRelay)
            .disposed(by: disposeBag)

        stateObservable
            .map(\.isValid)
            .bindAndCatch(to: continueButtonViewModel.isEnabledRelay)
            .disposed(by: disposeBag)

        passwordTextFieldViewModel.state
            .compactMap(\.value)
            .bindAndCatch(to: interactor.passwordRelay)
            .disposed(by: disposeBag)

        forgetWalletButtonViewModel.tapRelay
            .bind { [unowned self] in
                self.showForgetWalletAlert()
            }
            .disposed(by: disposeBag)

        forgotPasswordButtonViewModel.tapRelay
            .bind { [unowned self] in
                self.showSupportAlert()
            }
            .disposed(by: disposeBag)

        continueButtonViewModel.tapRelay
            .bind { [weak self] in
                self?.authenticate()
            }
            .disposed(by: disposeBag)

        interactor.error
            .bind { [weak self] error in
                self?.handle(error: error)
            }
            .disposed(by: disposeBag)
    }

    /// Should be invoked as the presenting view appears
    func viewWillAppear() {
        launchAnnouncementPresenter.execute()
    }

    // TODO: Refactor when the interaction layer and `AuthenticationCoordinator` are refactored.
    /// Handles any interaction error
    private func handle(error: Error) {
        alertPresenter.showKeychainReadError()
    }

    private func showForgetWalletAlert() {
        let title = LocalizedString.ForgetWalletAlert.title
        let message = LocalizedString.ForgetWalletAlert.message
        let okAction = UIAlertAction(title: LocalizedString.ForgetWalletAlert.forgetButton, style: .destructive) { _ in
            self.forgetWallet()
        }
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        alertPresenter.standardNotify(
            title: title,
            message: message,
            actions: [okAction, cancelAction]
        )
    }

    private func showSupportAlert() {
        let title = LocalizedString.ForgotPasswordAlert.title
        let message = String(format: LocalizedString.ForgotPasswordAlert.message, Constants.Url.blockchainSupport)
        let okAction = UIAlertAction(title: LocalizationConstants.continueString, style: .default) { _ in
            guard let url = URL(string: Constants.Url.forgotPassword) else { return }
            UIApplication.shared.open(url)
        }
        let cancelAction = UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        alertPresenter.standardNotify(
            title: title,
            message: message,
            actions: [okAction, cancelAction]
        )
    }

    /// Forgets the wallet and routes to the first onboarding screen
    private func forgetWallet() {
        interactor.forget()
        forgetWalletRouting?()
    }

    /// Authenticate
    private func authenticate() {
        loadingViewPresenter.showCircular(with: LocalizedString.loadingLabel)
        interactor.authenticate()
    }
}
