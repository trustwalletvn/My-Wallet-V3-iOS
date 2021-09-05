// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ActivityKit
import ActivityUIKit
import BitcoinCashKit
import BitcoinChainKit
import BitcoinKit
import Combine
import DebugUIKit
import DIKit
import EthereumKit
import FeatureAuthenticationData
import FeatureAuthenticationDomain
import Firebase
import FirebaseDynamicLinks
import KYCKit
import KYCUIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import RIBs
import RxSwift
import SettingsKit
import ToolKit
import TransactionDataKit
import TransactionUIKit
import WalletPayloadKit

@available(*, deprecated, message: "This is being replaced by newer AppDelegate @see App.swift file")
class BlockchainAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    private var isDebug: Bool {
        var isDebug = false
        #if DEBUG
        isDebug = true
        #endif
        return isDebug
    }

    private lazy var visualEffectView: UIVisualEffectView = {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        view.frame = UIScreen.main.bounds
        view.alpha = 0
        return view
    }()

    // MARK: - Properties

    /// The overlay shown when the application resigns active state.
    private lazy var deepLinkHandler: DeepLinkHandler = {
        DeepLinkHandler()
    }()

    @LazyInject private var deepLinkRouter: DeepLinkRouting

    @LazyInject private var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    @LazyInject private var supportedAssetsRemoteService: SupportedAssetsRemoteServiceAPI
    @LazyInject(tag: DebugScreenContext.tag) private var debugCoordinator: DebugCoordinating

    private let disposeBag = DisposeBag()
    private var appCoordinator: AppCoordinator { .shared }
    private lazy var bitpayRouter = BitPayLinkRouter()
    private var cancellables: Set<AnyCancellable> = []

    override init() {
        super.init()

        BuildFlag.isInternal = {
            #if INTERNAL_BUILD
            true
            #else
            false
            #endif
        }()

        FirebaseApp.configure()
        defineDependencies()
    }

    // MARK: - Lifecycle Methods

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if ProcessInfo.processInfo.environmentBoolean(for: .eraseWallet) == true {
            // If ProcessInfo environment contains "automation_erase_data": true, erase wallet and settings.
            // This behaviour happens even on non-debug builds, this is necessary because our UI tests
            //   run on real devices with 'release-staging' builds.
            WalletManager.shared.forgetWallet()
            BlockchainSettings.App.shared.clear()
        }

        // set the window before checking if running unit tests to support test targets that require a host application
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        if isDebug, ProcessInfo.processInfo.isUnitTesting {
            // If isDebug build, and we are running unit test, skip rest of AppDelegate.
            // but avoid crashing the app for Unit Tests that need to run in a target requiring a host app
            window?.setRootViewController(UIViewController()) // to avoid crashing unit tests that require, but don't set, a root VC
            return true
        }

        window?.backgroundColor = #colorLiteral(red: 0.0431372549, green: 0.1019607843, blue: 0.2784313725, alpha: 1)

        // Trigger routing hierarchy
        appCoordinator.window = window

        supportedAssetsRemoteService
            .refreshCustodialAssetsCache()
            .sink { _ in }
            .store(in: &cancellables)

        // Register the application for remote notifications
        remoteNotificationServiceContainer.authorizer
            .registerForRemoteNotificationsIfAuthorized()
            .subscribe()
            .disposed(by: disposeBag)

        // MARK: - Global Appearance

        //: Navigation Bar
        let defaultBarStyle = Screen.Style.Bar.lightContent()
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.shadowImage = UIImage()
        navigationBarAppearance.isTranslucent = defaultBarStyle.isTranslucent
        navigationBarAppearance.titleTextAttributes = defaultBarStyle.titleTextAttributes
        navigationBarAppearance.barTintColor = defaultBarStyle.backgroundColor
        navigationBarAppearance.tintColor = defaultBarStyle.tintColor

        #if INTERNAL_BUILD
        debugCoordinator.enableDebugMenu(for: window)
        #endif

        // TODO: prevent any other data tasks from executing until cert is pinned
        let certificatePinner: CertificatePinnerAPI = resolve()
        certificatePinner.pinCertificateIfNeeded()

        let sift: SiftServiceAPI = DIKit.resolve()
        sift.enable()

        checkForNewInstall()

        appCoordinator.start()

        KeychainItemWrapper.removeAllSwipeAddresses()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        changeBlurVisibility(true)
    }

    func delayedApplicationDidEnterBackground(_ application: UIApplication) {
        // Wallet-related background actions

        // TODO: This should be moved into a component that performs actions to the wallet
        // on different lifecycle events (e.g. "WalletAppLifecycleListener")
        let appSettings = BlockchainSettings.App.shared
        let wallet = WalletManager.shared.wallet

        if wallet.isInitialized() {
            if appSettings.guid != nil, appSettings.sharedKey != nil {
                appSettings.hasEndedFirstSession = true
            }
            WalletManager.shared.close()
        }

        // TODO: Remove this - we don't want any such logic in `AppDelegate`
        // We have to make sure the 2FA alerts (email / auth app) are still showing
        // when the user goes back to foreground
        if appCoordinator.onboardingRouter.state != .pending2FA {
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: false)
        }

        appCoordinator.cleanupOnAppBackgrounded()
        AuthenticationCoordinator.shared.cleanupOnAppBackgrounded()

        let defaultSession: URLSession = resolve()
        defaultSession.reset {
            Logger.shared.debug("URLSession reset completed.")
        }
    }

    var backgroundTaskTimer = BackgroundTaskTimer(
        invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier(identifier: UIBackgroundTaskIdentifier.invalid)
    )

    func applicationDidEnterBackground(_ application: UIApplication) {
        let portfolioSyncingService: BalanceSharingSettingsServiceAPI = resolve()
        portfolioSyncingService.sync()
        backgroundTaskTimer.begin(application) { [weak self] in
            self?.delayedApplicationDidEnterBackground(application)
        }
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        backgroundTaskTimer.stop(application)
        Logger.shared.debug("applicationWillEnterForeground")

        if !WalletManager.shared.wallet.isInitialized() {
            if BlockchainSettings.App.shared.guid != nil, BlockchainSettings.App.shared.sharedKey != nil {
                AuthenticationCoordinator.shared.start()
            } else {
                if appCoordinator.onboardingRouter.state == .standard {
                    appCoordinator.onboardingRouter.start(in: UIApplication.shared.keyWindow!)
                }
            }
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        changeBlurVisibility(false)
        Logger.shared.debug("applicationDidBecomeActive")
        UIApplication.shared.applicationIconBadgeNumber = 0
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        let urlString = url.absoluteString

        guard BlockchainSettings.App.shared.isPinSet else {
            if urlString == "\(AssetConstants.URLSchemes.blockchainWallet)loginAuthorized" {
                // TODO: Link to manual pairing
                appCoordinator.onboardingRouter.start()
                return true
            }
            return false
        }

        guard let urlScheme = url.scheme else {
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchainWallet {
            // Redirect from browser to app - do nothing.
            return true
        }

        if urlScheme == AssetConstants.URLSchemes.blockchain {
            return true
        }

        let isInitialized = WalletManager.shared.wallet.isInitialized()
        let hasGuid = BlockchainSettings.App.shared.guid != nil
        let hasSharedKey = BlockchainSettings.App.shared.sharedKey != nil
        let authenticated = isInitialized && hasGuid && hasSharedKey

        if BitPayLinkRouter.isBitPayURL(url) {
            BitpayService.shared.contentRelay.accept(url)
            guard authenticated else { return true }
            return bitpayRouter.routeIfNeeded()
        }

        // Handle "bitcoin://" scheme
        if BitcoinURLPayload(url: url) != nil {
            AuthenticationCoordinator.shared.postAuthenticationRoute = .sendCoins
            // TODO: Send P3: Handle deeplinks.
            return true
        }

        if authenticated {
            deepLinkRouter.routeIfNeeded()
            return true
        }

        return true
    }

    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any],
        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void
    ) {
        remoteNotificationServiceContainer.backgroundReceiver
            .didReceiveRemoteNotification(
                userInfo,
                onApplicationState: application.applicationState,
                fetchCompletionHandler: completionHandler
            )
    }

    func application(
        _ application: UIApplication,
        continue userActivity: NSUserActivity,
        restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
    ) -> Bool {
        guard let webpageUrl = userActivity.webpageURL else { return false }

        let handled = DynamicLinks.dynamicLinks().handleUniversalLink(webpageUrl) { [weak self] dynamicLink, error in
            guard error == nil else {
                Logger.shared.error("Got error handling universal link: \(String(describing: error!))")
                return
            }

            guard let deepLinkUrl = dynamicLink?.url else {
                return
            }

            // Check that the version of the link (if provided) is supported, if not, prompt the user to update
            if let minimumAppVersionStr = dynamicLink?.minimumAppVersion,
               let minimumAppVersion = AppVersion(string: minimumAppVersionStr),
               let appVersionStr = Bundle.applicationVersion,
               let appVersion = AppVersion(string: appVersionStr),
               appVersion < minimumAppVersion
            {
                self?.showUpdateAppAlert()
                return
            }

            Logger.shared.info("Deeplink: \(deepLinkUrl.absoluteString)")
            self?.deepLinkHandler.handle(deepLink: deepLinkUrl.absoluteString)
        }
        return handled
    }

    // MARK: - State Checks

    func checkForNewInstall() {

        let appSettings = BlockchainSettings.App.shared
        let onboardingSettings: OnboardingSettings = resolve()

        guard !onboardingSettings.firstRun else {
            Logger.shared.info("This is not the 1st time the user is running the app.")
            return
        }

        onboardingSettings.firstRun = true

        if appSettings.guid != nil, appSettings.sharedKey != nil, !appSettings.isPinSet {
            AlertViewPresenter.shared.alertUserAskingToUseOldKeychain { _ in
                AuthenticationCoordinator.shared.showPasswordRequiredViewController()
            }
        }
    }

    // MARK: - Blur

    private func changeBlurVisibility(_ isVisible: Bool) {
        let alpha: CGFloat = isVisible ? 1 : 0
        UIApplication.shared.keyWindow?.addSubview(visualEffectView)
        UIView.animate(
            withDuration: 0.12,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: {
                self.visualEffectView.alpha = alpha
            },
            completion: { finished in
                if finished {
                    if !isVisible {
                        self.visualEffectView.removeFromSuperview()
                    }
                }
            }
        )
    }

    // MARK: - Private

    private func showUpdateAppAlert() {
        let actions = [
            UIAlertAction(title: LocalizationConstants.DeepLink.updateNow, style: .default, handler: { _ in
                UIApplication.shared.openAppStore()
            }),
            UIAlertAction(title: LocalizationConstants.cancel, style: .cancel)
        ]
        AlertViewPresenter.shared.standardNotify(
            title: LocalizationConstants.DeepLink.deepLinkUpdateTitle,
            message: LocalizationConstants.DeepLink.deepLinkUpdateMessage,
            actions: actions
        )
    }
}

// MARK: - Remote Notification Registration

extension BlockchainAppDelegate {
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        remoteNotificationServiceContainer.tokenReceiver
            .appDidFailToRegisterForRemoteNotifications(with: error)
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        remoteNotificationServiceContainer.tokenReceiver
            .appDidRegisterForRemoteNotifications(with: deviceToken)
    }
}
