// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureAuthenticationUI
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import ToolKit
import UIKit
import WalletPayloadKit

/// Used for canceling publishers
private enum WalletCancelations {
    struct DecryptId: Hashable {}
    struct AuthenticationId: Hashable {}
    struct InitializationId: Hashable {}
    struct UpgradeId: Hashable {}
}

struct CoreAppState: Equatable {
    var onboarding: Onboarding.State? = .init()
    var loggedIn: LoggedIn.State?
    var alertContent: AlertViewContent?

    var isLoggedIn: Bool {
        onboarding == nil && loggedIn != nil
    }
}

public enum CoreAppAction: Equatable {
    case start
    case loggedIn(LoggedIn.Action)
    case onboarding(Onboarding.Action)
    case proceedToLoggedIn
    case appForegrounded
    case deeplink(DeeplinkOutcome)
    case requirePin
    // Wallet Related Actions
    case walletInitialized
    case fetchWallet(String)
    case authenticate
    case didDecryptWallet(WalletDecryption)
    case decryptionFailure(AuthenticationError)
    case authenticated(Result<Bool, AuthenticationError>)
    case setupPin
    case initializeWallet
    case walletNeedsUpgrade(Bool)
    case none
}

struct CoreAppEnvironment {
    var loadingViewPresenter: LoadingViewPresenting
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var walletManager: WalletManager
    var featureFlagsService: FeatureFlagsServiceAPI
    var appFeatureConfigurator: FeatureConfiguratorAPI // TODO: deprecated, use featureFlagsService instead
    var internalFeatureService: InternalFeatureFlagServiceAPI // TODO: deprecated, use featureFlagsService instead
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI
    var blockchainSettings: BlockchainSettingsAppAPI
    var credentialsStore: CredentialsStoreAPI
    var alertPresenter: AlertViewPresenterAPI
    var walletUpgradeService: WalletUpgradeServicing
    var exchangeRepository: ExchangeAccountRepositoryAPI
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var coincore: CoincoreAPI
    var sharedContainer: SharedContainerUserDefaults
    var analyticsRecorder: AnalyticsEventRecorderAPI
    var siftService: SiftServiceAPI
    var onboardingSettings: OnboardingSettingsAPI
    var mainQueue: AnySchedulerOf<DispatchQueue>
    var buildVersionProvider: () -> String
}

let mainAppReducer = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment>.combine(
    onBoardingReducer
        .optional()
        .pullback(
            state: \.onboarding,
            action: /CoreAppAction.onboarding,
            environment: { environment -> Onboarding.Environment in
                Onboarding.Environment(
                    appSettings: environment.blockchainSettings,
                    walletManager: environment.walletManager,
                    alertPresenter: environment.alertPresenter,
                    mainQueue: .main,
                    featureFlags: environment.internalFeatureService,
                    buildVersionProvider: environment.buildVersionProvider
                )
            }
        ),
    loggedInReducer
        .optional()
        .pullback(
            state: \.loggedIn,
            action: /CoreAppAction.loggedIn,
            environment: { environment -> LoggedIn.Environment in
                LoggedIn.Environment(
                    mainQueue: .main,
                    analyticsRecorder: environment.analyticsRecorder,
                    loadingViewPresenter: environment.loadingViewPresenter,
                    exchangeRepository: environment.exchangeRepository,
                    remoteNotificationTokenSender: environment.remoteNotificationServiceContainer.tokenSender,
                    remoteNotificationAuthorizer: environment.remoteNotificationServiceContainer.authorizer,
                    walletManager: environment.walletManager,
                    coincore: environment.coincore,
                    appSettings: environment.blockchainSettings,
                    deeplinkRouter: environment.deeplinkRouter,
                    featureFlagsService: environment.featureFlagsService,
                    fiatCurrencySettingsService: environment.fiatCurrencySettingsService
                )
            }
        ),
    mainAppReducerCore
)

let mainAppReducerCore = Reducer<CoreAppState, CoreAppAction, CoreAppEnvironment> { state, action, environment in
    switch action {
    case .start:
        return .merge(
            .fireAndForget {
                environment.appFeatureConfigurator.initialize()
            },
            .fireAndForget {
                syncPinKeyWithICloud(
                    blockchainSettings: environment.blockchainSettings,
                    credentialsStore: environment.credentialsStore
                )
            }
        )
    case .appForegrounded:
        // check if we need to display the pin for authentication
        guard environment.walletManager.wallet.isInitialized() else {
            // do nothing if we're on the authentication state,
            // meaning we either need to register, login or recover
            guard state.isLoggedIn else {
                return .none
            }
            // We need to send the `stop` action prior we show the pin entry,
            // this clears any running operation from the logged-in state.
            return .concatenate(
                Effect(value: .loggedIn(.stop)),
                Effect(value: .requirePin)
            )
        }
        return .none
    case .deeplink(.handleLink(let content)) where content.context == .dynamicLinks:
        // for context this performs side-effect to values in the appSettings
        // it'll then be up to the `DeeplinkRouter` to capture any of these changes
        // and route if needed, the router is handled once we're in a logged-in state
        environment.deeplinkHandler.handle(deepLink: content.url.absoluteString)
        return .none
    case .deeplink(.handleLink(let content)) where content.context.usableOnlyDuringAuthentication:
        guard let onboarding = state.onboarding else {
            return .none
        }
        // check if we're on the authentication state and the deeplink
        // currently we only support only one deeplink for login, so being naive here
        guard let authState = onboarding.welcomeState,
              content.context == .blockchainLinks(.login)
        else {
            return .none
        }
        // Pass content to welcomeScreen to be handled
        return Effect(value: .onboarding(.welcomeScreen(.deeplinkReceived(content.url))))
    case .deeplink(.handleLink(let content)):
        // we first check if we're logged in, if not we need to defer the deeplink routing
        guard state.isLoggedIn else {
            // continue if we're on the onboarding state
            guard let onboarding = state.onboarding else {
                return .none
            }
            // check if we're on the pinState and we need the user to enter their pin
            if let pinState = onboarding.pinState,
               pinState.requiresPinAuthentication,
               !content.context.usableOnlyDuringAuthentication
            {
                // defer the deeplink until we handle the `.proceedToLoggedIn` action
                state.onboarding?.deeplinkContent = content
            }
            return .none
        }
        // continue with the deeplink
        return Effect(value: .loggedIn(.deeplink(content)))
    case .deeplink(.informAppNeedsUpdate):
        // TODO: This is ugly, rethink how we handle alert actions
        let actions = [
            UIAlertAction(
                title: LocalizationConstants.DeepLink.updateNow,
                style: .default,
                handler: { _ in
                    UIApplication.shared.openAppStore()
                }
            ),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        state.alertContent = AlertViewContent(
            title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
            message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
            actions: actions
        )
        return .none
    case .deeplink(.ignore):
        return .none
    case .requirePin:
        state.loggedIn = nil
        state.onboarding = .init()
        return Effect(value: .onboarding(.start))
    case .fetchWallet(let password):
        environment.loadingViewPresenter.showCircular()
        environment.walletManager.wallet.fetch(with: password)
        return Effect(value: .authenticate)
    case .authenticate:
        let appSettings = environment.blockchainSettings
        return .merge(
            environment.walletManager.didDecryptWallet
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.DecryptId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case .success(let value) = result else {
                        return .none
                    }
                    return handleWalletDecryption(value)
                },
            environment.walletManager.didCompleteAuthentication
                .receive(on: environment.mainQueue)
                .catchToEffect()
                .cancellable(id: WalletCancelations.AuthenticationId(), cancelInFlight: false)
                .map { result -> CoreAppAction in
                    guard case .success(let value) = result else {
                        return CoreAppAction.authenticated(
                            .failure(.init(code: AuthenticationError.ErrorCode.unknown))
                        )
                    }
                    return CoreAppAction.authenticated(value)
                }
        )
    case .didDecryptWallet(let decryption):
        // defer showing the loading spinner, we should find a better way of dealing with this
        // for context the underlying implementation of showing the circular loader
        // relies on attaching the loader to the top window's view!!, this is error-prone and there are cases
        // where the loader would not show above a presented view controller...
        environment.loadingViewPresenter.hide()

        // skip saving guid and sharedKey if we detect a second password is needed
        // TODO: Refactor this so that we don't call legacy methods directly
        if environment.walletManager.wallet.needsSecondPassword(),
           state.onboarding?.welcomeState != nil
        {
            return .cancel(id: WalletCancelations.DecryptId())
        }

        environment.loadingViewPresenter.showCircular()
        environment.blockchainSettings.guid = decryption.guid
        environment.blockchainSettings.sharedKey = decryption.sharedKey

        return .merge(
            .cancel(id: WalletCancelations.DecryptId()),
            .fireAndForget {
                clearPinIfNeeded(
                    for: decryption.passwordPartHash,
                    appSettings: environment.blockchainSettings
                )
            }
        )
    case .decryptionFailure(let error):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.DecryptId())
    case .authenticated(.failure(let error)) where error.code == .failedToLoadWallet:
        guard state.onboarding?.welcomeState != nil else {
            state.onboarding?.displayAlert = .walletAuthentication(error)
            return .cancel(id: WalletCancelations.AuthenticationId())
        }
        return .merge(
            .cancel(id: WalletCancelations.AuthenticationId()),
            Effect(
                value: CoreAppAction.onboarding(
                    .welcomeScreen(
                        .emailLogin(
                            .verifyDevice(
                                .credentials(
                                    .password(
                                        .incorrectPasswordErrorVisibility(true)
                                    )
                                )
                            )
                        )
                    )
                )
            )
        )
    case .authenticated(.failure(let error)):
        state.onboarding?.displayAlert = .walletAuthentication(error)
        return .cancel(id: WalletCancelations.AuthenticationId())
    case .authenticated(.success):
        // when on authenticated success we need to check if the wallet
        // requires a second password, if we do then we stop the process
        // and display a notice to the user
        // TODO: Refactor this so that we don't call legacy methods directly
        if environment.walletManager.wallet.needsSecondPassword(),
           state.onboarding?.welcomeState != nil
        {
            // unfortunately during login we store the guid in the settings
            // we need to reset this if we detect a second password
            environment.blockchainSettings.guid = nil
            environment.blockchainSettings.sharedKey = nil
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(
                    value: .onboarding(.informSecondPasswordDetected)
                )
            )
        }
        // decide if we need to set a pin or not
        guard environment.blockchainSettings.isPinSet else {
            state.onboarding?.hideLegacyScreenIfNeeded()
            guard state.onboarding?.welcomeState != nil else {
                return .merge(
                    .cancel(id: WalletCancelations.AuthenticationId()),
                    Effect(value: .setupPin)
                )
            }
            return .merge(
                .cancel(id: WalletCancelations.AuthenticationId()),
                Effect(value: .onboarding(.welcomeScreen(.presentScreenFlow(.welcomeScreen)))),
                Effect(value: .setupPin)
            )
        }
        return .merge(
            .cancel(id: WalletCancelations.AuthenticationId()),
            Effect(value: .initializeWallet)
        )
    case .setupPin:
        state.onboarding?.pinState = .init()
        state.onboarding?.passwordScreen = nil
        return Effect(value: CoreAppAction.onboarding(.pin(.create)))
    case .initializeWallet:
        return environment.walletManager
            .reactiveWallet
            .waitUntilInitializedSinglePublisher
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.InitializationId(), cancelInFlight: false)
            .map { _ in CoreAppAction.walletInitialized }
    case .walletInitialized:
        return environment.walletUpgradeService
            .needsWalletUpgradePublisher
            .receive(on: environment.mainQueue)
            .catchToEffect()
            .cancellable(id: WalletCancelations.UpgradeId(), cancelInFlight: false)
            .map { result -> CoreAppAction in
                guard case .success(let shouldUpgrade) = result else {
                    // impossible with current `WalletUpgradeServicing` implementation
                    return CoreAppAction.proceedToLoggedIn
                }
                return CoreAppAction.walletNeedsUpgrade(shouldUpgrade)
            }
    case .walletNeedsUpgrade(let shouldUpgrade):
        // check if we need the wallet needs an upgrade otherwise proceed to logged in state
        guard shouldUpgrade else {
            return Effect(value: CoreAppAction.proceedToLoggedIn)
        }
        environment.loadingViewPresenter.hide()
        state.onboarding?.pinState = nil
        state.onboarding?.walletUpgradeState = WalletUpgrade.State()
        return .merge(
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(value: CoreAppAction.onboarding(.walletUpgrade(.begin)))
        )
    case .proceedToLoggedIn:
        environment.loadingViewPresenter.hide()
        // prepare the context for logged in state, if required
        var context: LoggedIn.Context = .none
        if let deeplinkContent = state.onboarding?.deeplinkContent {
            context = .deeplink(deeplinkContent)
        }
        if let walletContext = state.onboarding?.walletCreationContext {
            context = .wallet(walletContext)
        }
        state.loggedIn = LoggedIn.State()
        state.onboarding = nil
        return .merge(
            .cancel(id: WalletCancelations.InitializationId()),
            .cancel(id: WalletCancelations.UpgradeId()),
            Effect(
                value: CoreAppAction.loggedIn(.start(context))
            )
        )
    case .onboarding(.welcomeScreen(.presentScreenFlow(.createWalletScreen))):
        // send `authenticate` action so that we can listen for wallet creation
        return Effect(value: .authenticate)
    case .onboarding(.welcomeScreen(.presentScreenFlow(.recoverWalletScreen))):
        // send `authenticate` action so that we can listen for wallet creation or recovery
        return Effect(value: .authenticate)
    case .onboarding(.createAccountScreenClosed),
         .onboarding(.recoverWalletScreenClosed):
        // cancel any authentication publishers in case the create wallet is closed
        environment.loadingViewPresenter.hide()
        return .merge(
            .cancel(id: WalletCancelations.DecryptId()),
            .cancel(id: WalletCancelations.AuthenticationId())
        )
    case .onboarding(.walletUpgrade(.completed)):
        return Effect(
            value: CoreAppAction.proceedToLoggedIn
        )
    case .onboarding(.passwordScreen(.authenticate(let password))):
        return Effect(
            value: .fetchWallet(password)
        )
    case .onboarding(.pin(.handleAuthentication(let password))):
        return Effect(
            value: .fetchWallet(password)
        )
    case .onboarding(.pin(.pinCreated)):
        return Effect(
            value: .initializeWallet
        )
    case .onboarding(.welcomeScreen(.requestedToDecryptWallet(let password))):
        return Effect(
            value: .fetchWallet(password)
        )
    case .onboarding(.pin(.logout)),
         .loggedIn(.logout):
        // reset
        environment.walletManager.close()

        NotificationCenter.default.post(name: .logout, object: nil)
        environment.analyticsRecorder.record(event: AnalyticsEvents.New.Navigation.signedOut)

        environment.siftService.removeUserId()
        environment.sharedContainer.reset()
        environment.blockchainSettings.reset()
        environment.onboardingSettings.reset()

        // update state
        state.loggedIn = nil
        state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        // show password screen
        return Effect(value: .onboarding(.passwordScreen(.start)))
    case .onboarding:
        return .none
    case .loggedIn(.wallet(.authenticateForBiometrics(let password))):
        return Effect(value: .fetchWallet(password))
    case .loggedIn:
        return .none
    case .none:
        return .none
    }
}

// MARK: Private Methods

/// - Note:
/// In order to login to wallet, we need to know:
/// - GUID                 - To look up the wallet
/// - SharedKey            - To be able to read/write to the wallet db record (payload, settings, etc)
/// - EncryptedPinPassword - To decrypt the wallet
/// - PinKey               - Used in conjunction with the user's PIN to retrieve decryption key to the -  EncryptedPinPassword (EncryptedWalletPassword)
/// - PIN                  - Provided by the user or retrieved from secure enclave if Face/TouchID is enabled
///
/// In this method, we backup/restore the pinKey - which is essentially the identifier of the PIN.
/// Upon successful PIN authentication, we will backup/restore the remaining wallet details: guid, sharedKey, encryptedPinPassword.
///
/// The backup/restore of guid and sharedKey requires an encryption/decryption step when backing up and restoring respectively.
///
/// The key used to encrypt/decrypt the guid and sharedKey is provided in the response to a successful PIN auth attempt.
internal func syncPinKeyWithICloud(
    blockchainSettings: BlockchainSettingsAppAPI,
    credentialsStore: CredentialsStoreAPI
) {
    guard !blockchainSettings.isPairedWithWallet else {
        // Wallet is Paired, we do not need to restore.
        // We will back up after pin authentication
        return
    }

    if blockchainSettings.pinKey == nil,
       blockchainSettings.encryptedPinPassword == nil,
       blockchainSettings.guid == nil,
       blockchainSettings.sharedKey == nil
    {

        credentialsStore.synchronize()

        // Attempt to restore the pinKey from iCloud
        if let pinData = credentialsStore.pinData() {
            blockchainSettings.pinKey = pinData.pinKey
            blockchainSettings.encryptedPinPassword = pinData.encryptedPinPassword
        }
    }
}

func handleWalletDecryption(_ decryption: WalletDecryption) -> CoreAppAction {

    //// Verify valid GUID and sharedKey
    guard let guid = decryption.guid, guid.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.errorDecryptingWallet,
                description: LocalizationConstants.Authentication.errorDecryptingWallet
            )
        )
    }

    guard let sharedKey = decryption.sharedKey, sharedKey.count == 36 else {
        return .decryptionFailure(
            AuthenticationError(
                code: AuthenticationError.ErrorCode.invalidSharedKey,
                description: LocalizationConstants.Authentication.invalidSharedKey
            )
        )
    }

    return .didDecryptWallet(decryption)
}

func clearPinIfNeeded(for passwordPartHash: String?, appSettings: AppSettingsAuthenticating) {
    // Because we are not storing the password on the device. We record the first few letters of the hashed password.
    // With the hash prefix we can then figure out if the password changed. If so, clear the pin
    // so that the user can reset it
    guard let passwordPartHash = passwordPartHash,
          let savedPasswordPartHash = appSettings.passwordPartHash
    else {
        return
    }

    guard passwordPartHash != savedPasswordPartHash else {
        return
    }

    appSettings.clearPin()
}
