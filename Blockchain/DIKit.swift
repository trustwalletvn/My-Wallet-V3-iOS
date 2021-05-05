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
import KYCKit
import PlatformKit
import PlatformUIKit
import SettingsKit
import StellarKit
import ToolKit
import TransactionKit
import TransactionUIKit
import WalletPayloadKit

extension BackupFundsSettingsRouter: DashboardUIKit.BackupRouterAPI {}

extension AppCoordinator: DashboardUIKit.WalletOperationsRouting {}

extension AnalyticsUserPropertyInteractor: DashboardUIKit.AnalyticsUserPropertyInteracting {}

extension AnnouncementPresenter: DashboardUIKit.AnnouncementPresenting {}

extension DependencyContainer {
    
    // MARK: - Blockchain Module
    
    static var blockchain = module {
        
        factory { NavigationRouter() as NavigationRouterAPI }
        
        single { OnboardingSettings() }

        single { AuthenticationCoordinator() }

        single { OnboardingRouter() }
        
        factory { PaymentPresenter() }

        factory { AssetURLPayloadFactory() as AssetURLPayloadFactoryAPI }
        
        factory { RecoveryPhraseVerifyingService() as RecoveryPhraseVerifyingServiceAPI }

        factory { AirdropRouter() as AirdropRouterAPI }
        
        factory { AirdropCenterClient() as AirdropCenterClientAPI }
        
        factory { AirdropCenterService() as AirdropCenterServiceAPI }

        factory { DeepLinkHandler() as DeepLinkHandling }

        factory { DeepLinkRouter() as DeepLinkRouting }
        
        factory { UIDevice.current as DeviceInfo }

        single { [FirebaseAnalyticsService()] as [AnalyticsServiceProviding] }
        
        factory { CrashlyticsRecorder() as MessageRecording }
        
        factory { CrashlyticsRecorder() as ErrorRecording }
        
        factory(tag: "CrashlyticsRecorder") { CrashlyticsRecorder() as Recording }

        factory { ExchangeClient() as ExchangeClientAPI }
        
        factory { LockboxRepository() as LockboxRepositoryAPI }

        factory { BackupFundsCustodialRouter() as BackupRouterAPI }
                
        factory { RecoveryPhraseStatusProvider() as RecoveryPhraseStatusProviding }
        
        factory { DataProvider.default.historicalPrices as HistoricalFiatPriceProviding }
        
        factory { DataProvider.default.balanceChange as BalanceChangeProviding }
        
        single { TradeLimitsService() as TradeLimitsAPI }

        factory { SiftService() as SiftServiceAPI }

        single { SecondPasswordPrompter() as SecondPasswordPromptable }

        single { SecondPasswordStore() as SecondPasswordStorable }

        // MARK: - Dashboard
        
        factory { BackupFundsSettingsRouter() as DashboardUIKit.BackupRouterAPI }
        
        factory {
            AccountsRouter(
                routing: AppCoordinator.shared,
                balanceProvider: DataProvider.default.balance,
                backupRouter: BackupFundsSettingsRouter()
            ) as AccountsRouting
        }
        
        single { AppCoordinator.shared as DashboardUIKit.WalletOperationsRouting }
        
        factory { AnalyticsUserPropertyInteractor() as DashboardUIKit.AnalyticsUserPropertyInteracting }
        
        factory { AnnouncementPresenter() as DashboardUIKit.AnnouncementPresenting }
        
        factory { FiatBalanceCellProvider() as FiatBalanceCellProviding }
        
        factory { FiatBalanceCollectionViewInteractor() as FiatBalancesInteracting }
        
        factory { FiatBalanceCollectionViewPresenter(interactor: FiatBalanceCollectionViewInteractor()) as FiatBalanceCollectionViewPresenting }
        
        factory { SimpleBuyAnalyticsService() as PlatformKit.SimpleBuyAnalayticsServicing }
        
        factory { WithdrawalRouter() as WithdrawalRouting }
        
        // MARK: - Send

        factory { () -> SendScreenProvider in
            let manager: SendControllerManager = DIKit.resolve()
            return manager
        }

        single { SendControllerManager() }

        // MARK: - AppCoordinator

        single { AppCoordinator() }

        factory { () -> DrawerRouting in
            let app: AppCoordinator = DIKit.resolve()
            return app as DrawerRouting
        }

        // MARK: - WalletManager

        single { WalletManager() }

        factory { () -> ReactiveWalletAPI in
            let manager: WalletManager = DIKit.resolve()
            return manager.reactiveWallet
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

        // MARK: - AppFeatureConfigurator

        single { AppFeatureConfigurator() }

        factory { () -> FeatureConfiguring in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }

        factory { () -> FeatureFetching in
            let featureFetching: AppFeatureConfigurator = DIKit.resolve()
            return featureFetching
        }
        
        factory { () -> FeatureFetchingConfiguring in
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

        single { DataProvider() }

        factory { () -> DataProviding in
            let provider: DataProvider = DIKit.resolve()
            return provider as DataProviding
        }

        // MARK: - BlockchainDataRepository

        factory { BlockchainDataRepository.shared as DataRepositoryAPI }
        
        // MARK: - Ethereum Wallet

        factory { () -> EthereumWallet in
            let manager: WalletManager = DIKit.resolve()
            return manager.wallet.ethereum
        }

        factory { () -> ERC20BridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> EthereumWalletBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> EthereumWalletAccountBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> MnemonicAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory(tag: CryptoCurrency.ethereum) { () -> PasswordAccessAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum
        }

        factory { () -> CompleteEthereumWalletBridgeAPI in
            let ethereum: EthereumWallet = DIKit.resolve()
            return ethereum as CompleteEthereumWalletBridgeAPI
        }

        // MARK: - Stellar Wallet

        factory { StellarWallet() as StellarWalletBridgeAPI }
        
        // MARK: - BitcoinCash Wallet
        
        factory { BitcoinCashAddressValidator() as BitcoinCashAddressValidatorAPI }

        // MARK: - Bitcoin Wallet
        
        factory { BitcoinAddressValidator() as BitcoinAddressValidatorAPI }

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
    }
}
