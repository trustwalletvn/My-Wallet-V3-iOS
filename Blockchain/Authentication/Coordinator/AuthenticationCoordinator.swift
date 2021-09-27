// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BitcoinKit
import Combine
import DIKit
import FeatureAuthenticationDomain
import FeatureKYCUI
import FeatureOnboardingUI
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RxRelay
import RxSwift
import ToolKit

extension AuthenticationCoordinator {
    /// A new method for fetching wallet - is being used after manual pairing
    // TODO: Remove once done migrating JS to native
    func authenticate(using password: String) {
        loadingViewPresenter.showCircular()
        temporaryAuthHandler = authenticationHandler
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.walletManager.wallet.fetch(with: password)
        }
    }
}

@objc class AuthenticationCoordinator: NSObject, VersionUpdateAlertDisplaying {

    // MARK: - Types

    typealias WalletAuthHandler = (
        _ authenticated: Bool,
        _ twoFactorType: WalletAuthenticatorType?,
        _ error: AuthenticationError?
    ) -> Void

    @Inject @objc static var shared: AuthenticationCoordinator

    var postAuthenticationRoute: PostAuthenticationRoute?

    private var pinRouter: PinRouter!

    private let appSettings: BlockchainSettings.App
    private let onboardingSettings: OnboardingSettings
    private let wallet: Wallet
    private let remoteNotificationTokenSender: RemoteNotificationTokenSending
    private let remoteNotificationAuthorizer: RemoteNotificationAuthorizationRequesting

    private let alertPresenter: AlertViewPresenter
    private let loadingViewPresenter: LoadingViewPresenting
    private let dataRepository: BlockchainDataRepository
    private let walletManager: WalletManager
    private let fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    private let sharedContainter: SharedContainerUserDefaults
    @LazyInject private var secondPasswordPrompter: SecondPasswordPromptable

    private let deepLinkRouter: DeepLinkRouting

    private let onboardingRouter: FeatureOnboardingUI.OnboardingRouterAPI
    private let featureFlagsService: FeatureFlagsServiceAPI

    private var exchangeRepository: ExchangeAccountRepositoryAPI!
    private lazy var supportedPairsInteractor: SupportedPairsInteractorServiceAPI = resolve()
    @LazyInject private var coincore: CoincoreAPI

    @LazyInject private var analyticsRecoder: AnalyticsEventRecorderAPI

    // TODO: Delete when `AuthenticationCoordinator` is removed
    /// Temporary handler since `AuthenticationManager` was refactored.
    var temporaryAuthHandler: WalletAuthHandler?

    // TODO: Delete when `AuthenticationCoordiantor` is removed and
    /// `PasswordViewController` had it's own router.
    var isShowingSecondPasswordScreen = false

    var isCreatingWallet = false

    private let bag = DisposeBag()
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initializer

    init(
        fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI = resolve(),
        appSettings: BlockchainSettings.App = resolve(),
        sharedContainter: SharedContainerUserDefaults = .default,
        onboardingSettings: OnboardingSettings = resolve(),
        wallet: Wallet = WalletManager.shared.wallet,
        alertPresenter: AlertViewPresenter = resolve(),
        walletManager: WalletManager = WalletManager.shared,
        loadingViewPresenter: LoadingViewPresenting = resolve(),
        dataRepository: BlockchainDataRepository = BlockchainDataRepository.shared,
        deepLinkRouter: DeepLinkRouting = resolve(),
        onboardingRouter: FeatureOnboardingUI.OnboardingRouterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve(),
        remoteNotificationServiceContainer: RemoteNotificationServiceContaining = resolve()
    ) {
        self.sharedContainter = sharedContainter
        self.fiatCurrencySettingsService = fiatCurrencySettingsService
        self.appSettings = appSettings
        self.onboardingSettings = onboardingSettings
        self.wallet = wallet
        self.alertPresenter = alertPresenter
        self.walletManager = walletManager
        self.dataRepository = dataRepository
        self.deepLinkRouter = deepLinkRouter
        self.loadingViewPresenter = loadingViewPresenter
        self.featureFlagsService = featureFlagsService
        self.onboardingRouter = onboardingRouter
        remoteNotificationAuthorizer = remoteNotificationServiceContainer.authorizer
        remoteNotificationTokenSender = remoteNotificationServiceContainer.tokenSender
        super.init()
        self.walletManager.secondPasswordDelegate = self
        self.walletManager.authDelegate = self
    }

    /// Authentication handler - this should not be in AuthenticationCoordinator
    /// but the current way wallet creation is designed, we need to share this handler
    /// with that flow. Eventually, wallet creation should be moved with AuthenticationCoordinator
    @available(*, deprecated, message: "This method is deprected and its logic should be distributed to separate services")
    func authenticationHandler(
        _ isAuthenticated: Bool,
        _ twoFactorType: WalletAuthenticatorType?,
        _ error: AuthenticationError?
    ) {
        defer {
            self.loadingViewPresenter.hide()
        }

        // Error checking
        guard error == nil, isAuthenticated else {
            switch error!.code {
            case AuthenticationError.ErrorCode.noInternet:
                alertPresenter.internetConnection()
            case AuthenticationError.ErrorCode.failedToLoadWallet:
                handleFailedToLoadWallet()
            default:
                if let description = error!.description {
                    alertPresenter.standardError(message: description)
                }
            }
            return
        }

        alertPresenter.dismissIfNeeded()

        // Make user set up a pin if none is set. They can also optionally enable touch ID and link their email.
        guard appSettings.isPinSet else {
            showPinEntryView()
            return
        }

        if UIApplication.shared.keyWindow?.rootViewController?.topMostViewController != nil {
            alertPresenter.showMobileNoticeIfNeeded()
        }

        AppCoordinator.shared.startAfterWalletAuthentication(
            completion: { [weak self] in
                guard let self = self else { return }
                // Handle any necessary routing after authentication
                self.handlePostAuthenticationLogic()
            }
        )
    }

    private func handlePostAuthenticationLogic() {

        /// If the user has linked to the Exchange, we sync their addresses on authentication.
        exchangeRepository = ExchangeAccountRepository()
        exchangeRepository.syncDepositAddressesIfLinked()
            .subscribe()
            .disposed(by: bag)
        remoteNotificationTokenSender.sendTokenIfNeeded()
            .subscribe()
            .disposed(by: bag)
        remoteNotificationAuthorizer.requestAuthorizationIfNeeded()
            .subscribe()
            .disposed(by: bag)

        coincore.initialize()
            .subscribe()
            .store(in: &cancellables)

        NotificationCenter.default.post(name: .login, object: nil)
        analyticsRecoder.record(event: AnalyticsEvents.New.Navigation.signedIn)

        if isCreatingWallet {
            featureFlagsService.isEnabled(.remote(.showOnboardingAfterSignUp))
                .sink(receiveValue: { [presentOnboardingFlow, presentSimpleBuyFlow] showOnboardingAfterSignUp in
                    showOnboardingAfterSignUp ? presentOnboardingFlow() : presentSimpleBuyFlow()
                })
                .store(in: &cancellables)
        }

        if let route = postAuthenticationRoute {
            switch route {
            case .sendCoins:
                AppCoordinator.shared.tabControllerManager?.showSend()
            }
            postAuthenticationRoute = nil
        }

        // Handle airdrop routing
        deepLinkRouter.routeIfNeeded()
    }

    // MARK: - Start Flows

    /// Starts the authentication flow. If the user has a pin set, it will trigger
    /// present the pin entry screen, otherwise, it will show the password screen.
    func start() {
        if appSettings.isPinSet {
            authenticatePin()
        } else {
            showPasswordRequiredViewController()
        }
    }

    /// Unauthenticates the user
    @objc func logout() {

        // In case the user has created the wallet during this session
        // TODO: Refactor this once the wallet creation becomes native
        isCreatingWallet = false

        WalletManager.shared.close()

        NotificationCenter.default.post(name: .logout, object: nil)
        analyticsRecoder.record(event: AnalyticsEvents.New.Navigation.signedOut)

        let sift: SiftServiceAPI = resolve()
        sift.removeUserId()
        sharedContainter.reset()
        appSettings.reset()
        onboardingSettings.reset()

        showPasswordRequiredViewController()
        AppCoordinator.shared.clearOnLogout()
    }

    /// Cleanup any running authentication flows when the app is backgrounded.
    func cleanupOnAppBackgrounded() {
        guard let pinRouter = pinRouter,
              pinRouter.isBeingDisplayed,
              !pinRouter.flow.isLoginAuthentication
        else {
            return
        }
        pinRouter.cleanup()
    }

    // MARK: - Password Presentation

    @objc func showPasswordRequiredViewController() {
        guard let window = UIApplication.shared.keyWindow else { return }
        let walletFetcher: (String) -> Void = { [weak self] password in
            self?.authenticate(using: password)
        }
        let interactor = PasswordRequiredScreenInteractor(walletFetcher: walletFetcher)

        let forgetWalletRouting: () -> Void = {
            AppCoordinator.shared.onboardingRouter.start()
        }
        let presenter = PasswordRequiredScreenPresenter(interactor: interactor, forgetWalletRouting: forgetWalletRouting)
        let viewController = PasswordRequiredViewController(presenter: presenter)
        let navigationController = UINavigationController(rootViewController: viewController)
        // Sets view controller as rootViewController of the window
        window.setRootViewController(navigationController)
    }

    ///   - type: The type of the screen
    ///   - confirmHandler: Confirmation handler, receives the password
    ///   - dismissHandler: Dismiss handler (optional - defaults to `nil`)
    func showPasswordScreen(
        type: PasswordScreenType,
        confirmHandler: @escaping PasswordScreenPresenter.ConfirmHandler,
        dismissHandler: PasswordScreenPresenter.DismissHandler? = nil
    ) {
        guard !isShowingSecondPasswordScreen else { return }
        guard let parent = UIApplication.shared.topMostViewController else {
            return
        }
        isShowingSecondPasswordScreen = true

        let navigationController = UINavigationController()

        let confirm: PasswordScreenPresenter.ConfirmHandler = { [weak navigationController] password in
            navigationController?.dismiss(animated: true) {
                confirmHandler(password)
            }
        }

        let dismiss: PasswordScreenPresenter.DismissHandler = { [weak navigationController] in
            navigationController?.dismiss(animated: true) {
                dismissHandler?()
            }
        }

        loadingViewPresenter.hide()
        let interactor = PasswordScreenInteractor(type: type)
        let presenter = PasswordScreenPresenter(
            interactor: interactor,
            confirmHandler: confirm,
            dismissHandler: dismiss
        )
        let viewController = PasswordViewController(presenter: presenter)
        navigationController.viewControllers = [viewController]
        parent.present(navigationController, animated: true, completion: nil)
    }

    /// ObjC compatible version of `showPasswordScreen`
    @objc func showPasswordScreen(
        confirmHandler: @escaping PasswordScreenPresenter.ConfirmHandler,
        dismissHandler: PasswordScreenPresenter.DismissHandler? = nil
    ) {
        showPasswordScreen(
            type: .actionRequiresPassword,
            confirmHandler: confirmHandler,
            dismissHandler: dismissHandler
        )
    }

    // MARK: Email Verification

    private func presentOnboardingFlow() {
        guard let viewController = UIApplication.shared.topMostViewController else {
            fatalError("🔴 Could not present Email Verification Flow: topMostViewController is nil!")
        }
        onboardingRouter.presentOnboarding(from: viewController)
            .sink { onboardingResult in
                Logger.shared.debug("[AuthenticationCoordinator] Onboarding completed with result: \(onboardingResult)")
                viewController.dismiss(animated: true, completion: nil)
            }
            .store(in: &cancellables)
    }

    // MARK: Simple Buy

    private func presentSimpleBuyFlow() {
        fiatCurrencySettingsService.update(currency: .locale, context: .walletCreation)
            .asPublisher()
            .receive(on: DispatchQueue.main)
            .sink { completion in
                if case .finished = completion {
                    AppCoordinator.shared.startSimpleBuyAtLogin()
                }
            } receiveValue: { _ in
                // noop: this is not called
            }
            .store(in: &cancellables)
    }
}

// MARK: - WalletSecondPasswordDelegate

extension AuthenticationCoordinator: WalletSecondPasswordDelegate {
    func getSecondPassword(success: WalletSuccessCallback, dismiss: WalletDismissCallback?) {
        secondPasswordPrompter.secondPasswordIfNeeded(type: .actionRequiresPassword)
            .subscribe(
                onSuccess: { secondPassword in
                    success.success(string: secondPassword!)
                },
                onError: { _ in
                    dismiss?.dismiss()
                }
            )
            .disposed(by: bag)
    }

    func getPrivateKeyPassword(success: WalletSuccessCallback) {
        showPasswordScreen(
            type: .importPrivateKey,
            confirmHandler: {
                success.success(string: $0)
            }
        )
    }
}

extension AuthenticationCoordinator: WalletAuthDelegate {
    func didDecryptWallet(guid: String?, sharedKey: String?, password: String?) {

        // Verify valid GUID and sharedKey
        guard let guid = guid, guid.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            ))
            return
        }

        guard let sharedKey = sharedKey, sharedKey.count == 36 else {
            failAuth(withError: AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey,
                description: LocalizationConstants.Authentication.invalidSharedKey
            ))
            return
        }

        appSettings.guid = guid
        appSettings.sharedKey = sharedKey

        clearPinIfNeeded(for: password)
    }

    private func clearPinIfNeeded(for password: String?) {
        // Because we are not storing the password on the device. We record the first few letters of the hashed password.
        // With the hash prefix we can then figure out if the password changed. If so, clear the pin
        // so that the user can reset it
        guard let password = password,
              let passwordPartHash = password.passwordPartHash,
              let savedPasswordPartHash = appSettings.passwordPartHash
        else {
            return
        }

        guard passwordPartHash != savedPasswordPartHash else {
            return
        }

        BlockchainSettings.App.shared.clearPin()
    }

    func authenticationError(error: AuthenticationError?) {
        failAuth(withError: error)
    }

    func authenticationCompleted() {
        temporaryAuthHandler?(true, nil, nil)
    }

    private func failAuth(withError error: AuthenticationError? = nil) {
        temporaryAuthHandler?(false, nil, error)
    }
}

// MARK: - Pin Authentication

/// Used as a gateway to abstract any pin related login
extension AuthenticationCoordinator {

    /// Returns `true` in case the login pin screen is displayed
    @objc var isDisplayingLoginAuthenticationFlow: Bool {
        pinRouter?.isDisplayingLoginAuthentication ?? false
    }

    /// Change existing pin code. Used from settings mostly.
    func changePin() {
        let logout = { [weak self] () -> Void in
            self?.logout()
        }
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.change(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow)
        pinRouter.execute()
    }

    /// Create a new pin code. Used during onboarding, when the user is required to define a pin code before entering his wallet.
    func createPin() {
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.create(parent: boxedParent)
        pinRouter = PinRouter(flow: flow) { [weak self] _ in
            guard let self = self else { return }
            self.alertPresenter.showMobileNoticeIfNeeded()
            // TODO: Inject app coordinator instead - currently there is
            /// a crash related to circle-dependency between `AuthenticationCoordinator`
            /// and `AppCoordinator`.
            AppCoordinator.shared.startAfterWalletAuthentication(
                completion: { [weak self] in
                    // Handle any necessary routing after authentication
                    self?.handlePostAuthenticationLogic()
                }
            )
        }
        pinRouter.execute()
    }

    /// Authenticate using a pin code. Used during login when the app enters active state.
    func authenticatePin() {
        // If already authenticating, skip this as the screen is already presented
        guard pinRouter == nil || !pinRouter.isDisplayingLoginAuthentication else {
            return
        }
        let flow = PinRouting.Flow.authenticate(
            from: .background,
            logoutRouting: logout
        )
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.authenticate(using: password)
        }
        pinRouter.execute()
    }

    /// Validates pin for any in-app flow, for example: enabling touch-id/face-id auth.
    func enableBiometrics() {
        let logout = { [weak self] () -> Void in
            self?.logout()
        }
        let parentViewController = UIApplication.shared.topMostViewController!
        let boxedParent = UnretainedContentBox(parentViewController)
        let flow = PinRouting.Flow.enableBiometrics(parent: boxedParent, logoutRouting: logout)
        pinRouter = PinRouter(flow: flow) { [weak self] input in
            guard let password = input.password else { return }
            self?.authenticate(using: password)
        }
        pinRouter.execute()
    }

    // TODO: Dump this in favor of using one of the new gateways to PIN flow.
    /// Shows the pin entry view.
    func showPinEntryView() {
        if walletManager.didChangePassword {
            showPasswordRequiredViewController()
        } else if appSettings.isPinSet {
            authenticatePin()
        } else {
            createPin()
        }
    }
}

// TODO: Move out of `AuthenticationCoordinator`
extension AuthenticationCoordinator {
    // MARK: - Private

    private func handleFailedToLoadWallet() {
        guard let topMostViewController = UIApplication.shared.topMostViewController else {
            return
        }

        let alertController = UIAlertController(
            title: LocalizationConstants.Authentication.failedToLoadWallet,
            message: LocalizationConstants.Authentication.failedToLoadWalletDetail,
            preferredStyle: .alert
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in

                let forgetWalletAlert = UIAlertController(
                    title: LocalizationConstants.Errors.warning,
                    message: LocalizationConstants.Authentication.forgetWalletDetail,
                    preferredStyle: .alert
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.cancel, style: .cancel) { [unowned self] _ in
                        self.handleFailedToLoadWallet()
                    }
                )
                forgetWalletAlert.addAction(
                    UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { [unowned self] _ in
                        self.walletManager.forgetWallet()
                        AppCoordinator.shared.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
                    }
                )
                topMostViewController.present(forgetWalletAlert, animated: true)
            }
        )
        alertController.addAction(
            UIAlertAction(title: LocalizationConstants.Authentication.forgetWallet, style: .default) { _ in
                UIApplication.shared.suspendApp()
            }
        )
        topMostViewController.present(alertController, animated: true)
    }
}
