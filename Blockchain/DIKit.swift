// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import BitcoinCashKit
import BitcoinChainKit
import BitcoinKit
import DashboardUIKit
import DebugUIKit
import DIKit
import ERC20Kit
import EthereumKit
import FeatureAuthenticationData
import FeatureAuthenticationDomain
import KYCKit
import KYCUIKit
import NetworkKit
import OnboardingKit
import OnboardingUIKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import SettingsUIKit
import StellarKit
import ToolKit
import TransactionKit
import TransactionUIKit
import WalletPayloadKit

// MARK: - Settings Dependencies

extension AuthenticationCoordinator: SettingsUIKit.AuthenticationCoordinating {}

extension AppCoordinator: SettingsUIKit.AppCoordinating {}

extension ExchangeCoordinator: SettingsUIKit.ExchangeCoordinating {}

extension UIApplication: SettingsUIKit.AppStoreOpening {}

extension Wallet: WalletRecoveryVerifing {}

// MARK: - Dashboard Dependencies

extension AppCoordinator: DashboardUIKit.WalletOperationsRouting {}

extension AnalyticsUserPropertyInteractor: DashboardUIKit.AnalyticsUserPropertyInteracting {}

extension AnnouncementPresenter: DashboardUIKit.AnnouncementPresenting {}

extension SettingsUIKit.BackupFundsRouter: DashboardUIKit.BackupRouterAPI {}

// MARK: - FeatureAuthentication Dependencies

extension Wallet: WalletFeatureAuthenticationDomainWrapper {}

// MARK: - AnalyticsKit Dependencies

extension BlockchainSettings.App: AnalyticsKit.GuidRepositoryAPI {}

extension NabuTokenStore: AnalyticsKit.TokenRepositoryAPI {}

// MARK: - Blockchain Module

extension DependencyContainer {

    // swiftlint:disable closure_body_length
    static var blockchain = module {

        factory { NavigationRouter() as NavigationRouterAPI }

        single { OnboardingSettings() }

        factory { () -> OnboardingSettingsAPI in
            let settings: OnboardingSettings = DIKit.resolve()
            return settings as OnboardingSettingsAPI
        }

        single { OnboardingRouter() }

        factory { () -> OnboardingRouterStateProviding in
            let router: OnboardingRouter = DIKit.resolve()
            return router as OnboardingRouterStateProviding
        }

        single { () -> BackgroundAppHandlerAPI in
            let timer = BackgroundTaskTimer(
                invalidBackgroundTaskIdentifier: BackgroundTaskIdentifier(
                    identifier: UIBackgroundTaskIdentifier.invalid
                )
            )
            return BackgroundAppHandler(backgroundTaskTimer: timer)
        }

        factory { AirdropRouter() as AirdropRouterAPI }

        factory { AirdropCenterClient() as AirdropCenterClientAPI }

        factory { AirdropCenterService() as AirdropCenterServiceAPI }

        factory { DeepLinkHandler() as DeepLinkHandling }

        factory { DeepLinkRouter() as DeepLinkRouting }

        factory { UIDevice.current as DeviceInfo }

        factory { CrashlyticsRecorder() as MessageRecording }

        factory { CrashlyticsRecorder() as ErrorRecording }

        factory(tag: "CrashlyticsRecorder") { CrashlyticsRecorder() as Recording }

        factory { ExchangeClient() as ExchangeClientAPI }

        factory { LockboxRepository() as LockboxRepositoryAPI }

        factory { RecoveryPhraseStatusProvider() as RecoveryPhraseStatusProviding }

        single { TradeLimitsService() as TradeLimitsAPI }

        factory { SiftService() as SiftServiceAPI }

        single { SecondPasswordPrompter() as SecondPasswordPromptable }

        single { SecondPasswordStore() as SecondPasswordStorable }

        single { () -> AppDeeplinkHandlerAPI in
            let appSettings: BlockchainSettings.App = DIKit.resolve()
            let isPinSet: () -> Bool = { appSettings.isPinSet }
            let deeplinkHandler = CoreDeeplinkHandler(isPinSet: isPinSet)
            let blockchainHandler = BlockchainLinksHandler(
                validHosts: BlockchainLinks.validLinks,
                validRoutes: BlockchainLinks.validRoutes
            )
            return AppDeeplinkHandler(
                deeplinkHandler: deeplinkHandler,
                blockchainHandler: blockchainHandler,
                firebaseHandler: FirebaseDeeplinkHandler()
            )
        }

        // MARK: ExchangeCoordinator

        factory { ExchangeCoordinator.shared }

        factory { () -> ExchangeCoordinating in
            let coordinator: ExchangeCoordinator = DIKit.resolve()
            return coordinator as ExchangeCoordinating
        }

        // MARK: - AuthenticationCoordinator

        single { AuthenticationCoordinator() }

        factory { AuthenticationCoordinator.shared as WalletPairingFetcherAPI }

        factory { () -> AuthenticationCoordinating in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveAuthenticationCoordinating() as AuthenticationCoordinating
        }

        // MARK: - Dashboard

        factory { () -> AccountsRouting in
            let routing: CurrencyRouting & TabSwapping = DIKit.resolve()
            return AccountsRouter(
                routing: routing
            )
        }

        factory { UIApplication.shared as AppStoreOpening }

        factory {
            BackupFundsRouter(entry: .custody, navigationRouter: NavigationRouter()) as DashboardUIKit.BackupRouterAPI
        }

        factory { AnalyticsUserPropertyInteractor() as DashboardUIKit.AnalyticsUserPropertyInteracting }

        factory { AnnouncementPresenter() as DashboardUIKit.AnnouncementPresenting }

        factory { FiatBalanceCellProvider() as FiatBalanceCellProviding }

        factory { FiatBalanceCollectionViewInteractor() as FiatBalancesInteracting }

        factory { FiatBalanceCollectionViewPresenter(interactor: FiatBalanceCollectionViewInteractor())
            as FiatBalanceCollectionViewPresenting
        }

        factory { SimpleBuyAnalyticsService() as PlatformKit.SimpleBuyAnalayticsServicing }

        factory { WithdrawalRouter() as WithdrawalRouting }

        // MARK: - AppCoordinator

        single { AppCoordinator() }

        single { LoggedInDependencyBridge() as LoggedInDependencyBridgeAPI }

        factory { () -> CurrencyRouting & TabSwapping in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveCurrencyRoutingAndTabSwapping() as CurrencyRouting & TabSwapping
        }

        factory { () -> CurrencyRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveCurrencyRouting() as CurrencyRouting
        }

        factory { () -> TabSwapping in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveTabSwapping() as TabSwapping
        }

        factory { () -> AppCoordinating in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveAppCoordinating() as AppCoordinating
        }

        factory { () -> DashboardUIKit.WalletOperationsRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveWalletOperationsRouting() as DashboardUIKit.WalletOperationsRouting
        }

        factory { () -> BackupFlowStarterAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveBackupFlowStarter() as BackupFlowStarterAPI
        }

        factory { () -> CashIdentityVerificationAnnouncementRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveCashIdentityVerificationAnnouncementRouting()
                as CashIdentityVerificationAnnouncementRouting
        }

        factory { () -> InterestIdentityVerificationAnnouncementRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveInterestIdentityVerificationAnnouncementRouting()
                as InterestIdentityVerificationAnnouncementRouting
        }

        factory { () -> SettingsStarterAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveSettingsStarter() as SettingsStarterAPI
        }

        factory { () -> TabControllerManagerProvider in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveTabControllerProvider() as TabControllerManagerProvider
        }

        factory { () -> DrawerRouting in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveDrawerRouting() as DrawerRouting
        }

        factory { () -> LoggedInReloadAPI in
            let bridge: LoggedInDependencyBridgeAPI = DIKit.resolve()
            return bridge.resolveLoggedInReload() as LoggedInReloadAPI
        }

        factory { () -> ClearOnLogoutAPI in
            EmptyClearOnLogout()
        }

        // MARK: - WalletManager

        single { WalletManager() }

        factory { () -> WalletManagerReactiveAPI in
            let manager: WalletManager = DIKit.resolve()
            return manager
        }

        factory { () -> MnemonicAccessAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet as MnemonicAccessAPI
        }

        factory { () -> WalletRepositoryProvider in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as WalletRepositoryProvider
        }

        factory { () -> JSContextProviderAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager as JSContextProviderAPI
        }

        factory { () -> WalletRecoveryVerifing in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet as WalletRecoveryVerifing
        }

        factory { () -> SharedKeyRepositoryAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.repository as SharedKeyRepositoryAPI
        }

        factory { () -> FeatureAuthenticationDomain.GuidRepositoryAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.repository as FeatureAuthenticationDomain.GuidRepositoryAPI
        }

        factory { () -> PasswordRepositoryAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.repository as PasswordRepositoryAPI
        }

        // MARK: - BlockchainSettings.App

        single { KeychainItemSwiftWrapper() as KeychainItemWrapping }

        factory { LegacyPasswordProvider() as LegacyPasswordProviding }

        single { BlockchainSettings.App() }

        factory { () -> AppSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAPI
        }

        factory { () -> AppSettingsAuthenticating in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsAuthenticating
        }

        factory { () -> PermissionSettingsAPI in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app
        }

        factory { () -> AppSettingsSecureChannel in
            let app: BlockchainSettings.App = DIKit.resolve()
            return app as AppSettingsSecureChannel
        }

        // MARK: - Settings

        factory { () -> RecoveryPhraseVerifyingServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return RecoveryPhraseVerifyingService(wallet: manager.wallet) as RecoveryPhraseVerifyingServiceAPI
        }

        // MARK: - AppFeatureConfigurator

        single { AppFeatureConfigurator() }

        factory { () -> FeatureConfiguratorAPI in
            let configurator: AppFeatureConfigurator = DIKit.resolve()
            return configurator
        }

        factory { () -> FeatureConfiguring in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureVariantFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        // MARK: - UserInformationServiceProvider

        factory { () -> SettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> FiatCurrencyServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        factory { () -> MobileSettingsServiceAPI in
            let completeSettingsService: CompleteSettingsServiceAPI = DIKit.resolve()
            return completeSettingsService
        }

        // MARK: - DataProvider

        single { DataProvider() as DataProviding }

        factory { () -> ExchangeProviding in
            let provider: DataProviding = DIKit.resolve()
            return provider.exchange
        }

        factory { () -> HistoricalFiatPriceProviding in
            let provider: DataProviding = DIKit.resolve()
            return provider.historicalPrices
        }

        // MARK: - BlockchainDataRepository

        factory { BlockchainDataRepository.shared as DataRepositoryAPI }

        // MARK: - Ethereum Wallet

        factory { () -> EthereumWallet in
            let manager: WalletManager = DIKit.resolve()
            return manager.wallet.ethereum
        }

        factory { () -> EthereumWalletBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> EthereumWalletAccountBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.coin(.ethereum)) { () -> MnemonicAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.coin(.ethereum)) { () -> PasswordAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> CompleteEthereumWalletBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum as CompleteEthereumWalletBridgeAPI
        }

        // MARK: - Stellar Wallet

        factory { StellarWallet() as StellarWalletBridgeAPI }

        factory { () -> BitcoinWalletBridgeAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet.bitcoin
        }

        factory { () -> BitcoinChainSendBridgeAPI in
            let walletManager: WalletManager = DIKit.resolve()
            return walletManager.wallet.bitcoin
        }

        single { BitcoinCashWallet() as BitcoinCashWalletBridgeAPI }

        // MARK: Wallet Upgrade

        factory { WalletUpgrading() as WalletUpgradingAPI }

        // MARK: Remote Notifications

        factory { ExternalNotificationServiceProvider() as ExternalNotificationProviding }

        factory { () -> RemoteNotificationEmitting in
            let relay: RemoteNotificationRelay = DIKit.resolve()
            return relay as RemoteNotificationEmitting
        }

        factory { () -> RemoteNotificationBackgroundReceiving in
            let relay: RemoteNotificationRelay = DIKit.resolve()
            return relay as RemoteNotificationBackgroundReceiving
        }

        single { RemoteNotificationRelay() }

        // MARK: Helpers

        factory { UIApplication.shared as ExternalAppOpener }

        // MARK: KYC Module

        factory { () -> KYCUIKit.Routing in
            let emailVerificationService: KYCKit.EmailVerificationServiceAPI = DIKit.resolve()
            let externalAppOpener: ExternalAppOpener = DIKit.resolve()
            return KYCUIKit.Router(
                analyticsRecorder: DIKit.resolve(),
                legacyRouter: DIKit.resolve(),
                kycService: DIKit.resolve(),
                emailVerificationService: emailVerificationService,
                openMailApp: externalAppOpener.openMailApp
            )
        }

        factory { () -> KYCKit.EmailVerificationAPI in
            EmailVerificationAdapter(settingsService: DIKit.resolve())
        }

        factory { () -> PlatformUIKit.TierUpgradeRouterAPI in
            KYCAdapter()
        }

        // MARK: Onboarding Module

        // this must be kept in memory because of how PlatformUIKit.Router works, otherwise the flow crashes.
        single { () -> OnboardingUIKit.OnboardingRouterAPI in
            OnboardingUIKit.OnboardingRouter()
        }

        factory { () -> OnboardingUIKit.BuyCryptoRouterAPI in
            TransactionsAdapter()
        }

        factory { () -> OnboardingUIKit.EmailVerificationRouterAPI in
            KYCAdapter()
        }

        // MARK: Transactions Module

        factory { () -> TransactionsAdapterAPI in
            TransactionsAdapter()
        }

        factory { () -> PlatformUIKit.KYCRouting in
            KYCAdapter()
        }

        factory { () -> TransactionUIKit.KYCSDDServiceAPI in
            TransactionsKYCAdapter()
        }

        // MARK: FeatureAuthentication Module

        factory { () -> AutoWalletPairingServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return AutoWalletPairingService(repository: manager.repository) as AutoWalletPairingServiceAPI
        }

        factory { () -> GuidServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return GuidService(sessionTokenRepository: manager.repository, client: DIKit.resolve())
        }

        factory { () -> SessionTokenServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return sessionTokenServiceFactory(walletRepository: manager.repository)
        }

        factory { () -> SMSServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return SMSService(client: DIKit.resolve(), repository: manager.repository)
        }

        factory { () -> TwoFAWalletServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return TwoFAWalletService(client: DIKit.resolve(), repository: manager.repository)
        }

        factory { () -> WalletPayloadServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return WalletPayloadService(client: DIKit.resolve(), repository: manager.repository)
        }

        factory { () -> LoginServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return LoginService(
                payloadService: DIKit.resolve(),
                twoFAPayloadService: DIKit.resolve(),
                repository: manager.repository
            )
        }

        factory { () -> EmailAuthorizationServiceAPI in
            EmailAuthorizationService(guidService: DIKit.resolve()) as EmailAuthorizationServiceAPI
        }

        factory { () -> DeviceVerificationServiceAPI in
            let manager: WalletManager = DIKit.resolve()
            return DeviceVerificationService(
                sessionTokenRepository: manager.repository
            ) as DeviceVerificationServiceAPI
        }

        factory { RecaptchaClient(siteKey: AuthenticationKeys.googleRecaptchaSiteKey) }

        factory { GoogleRecaptchaService() as GoogleRecaptchaServiceAPI }

        factory { () -> WalletFeatureAuthenticationDomainWrapper in
            let manager: WalletManager = DIKit.resolve()
            return manager.wallet as WalletFeatureAuthenticationDomainWrapper
        }

        // MARK: Analytics

        single { () -> AnalyticsKit.TokenRepositoryAPI in
            let tokenRepository: NabuTokenStore = DIKit.resolve()
            return tokenRepository as AnalyticsKit.TokenRepositoryAPI
        }

        single { () -> AnalyticsKit.GuidRepositoryAPI in
            let guidRepository: BlockchainSettings.App = DIKit.resolve()
            return guidRepository as AnalyticsKit.GuidRepositoryAPI
        }

        single { () -> AnalyticsEventRecorderAPI in
            let firebaseAnalyticsServiceProvider = FirebaseAnalyticsServiceProvider()
            let userAgent = UserAgentProvider().userAgent ?? ""
            let nabuAnalyticsServiceProvider = NabuAnalyticsProvider(
                platform: .wallet,
                basePath: BlockchainAPI.shared.apiUrl,
                userAgent: userAgent,
                tokenRepository: DIKit.resolve(),
                guidProvider: DIKit.resolve()
            )
            return AnalyticsEventRecorder(analyticsServiceProviders: [
                firebaseAnalyticsServiceProvider,
                nabuAnalyticsServiceProvider
            ])
        }
    }
}
