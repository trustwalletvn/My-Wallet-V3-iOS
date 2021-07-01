// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import ComposableArchitecture
import DebugUIKit
import DIKit
import NetworkKit
import PlatformKit
import PlatformUIKit
import RemoteNotificationsKit
import SettingsKit
import ToolKit
import WalletPayloadKit

public struct AppEnvironment {
    public var debugCoordinator: DebugCoordinating

    var loadingViewPresenter: LoadingViewPresenting
    var onboardingSettings: OnboardingSettings
    var blurEffectHandler: BlurVisualEffectHandler
    var appCoordinator: AppCoordinator
    var cacheSuite: CacheSuite
    var remoteNotificationServiceContainer: RemoteNotificationServiceContaining
    var certificatePinner: CertificatePinnerAPI
    var siftService: SiftServiceAPI
    var alertViewPresenter: AlertViewPresenterAPI
    var deeplinkAppHandler: AppDeeplinkHandlerAPI
    var deeplinkHandler: DeepLinkHandling
    var deeplinkRouter: DeepLinkRouting
    var backgroundAppHandler: BackgroundAppHandlerAPI
    var portfolioSyncingService: BalanceSharingSettingsServiceAPI
    var internalFeatureService: InternalFeatureFlagServiceAPI
    var fiatCurrencySettingsService: FiatCurrencySettingsServiceAPI

    var sharedContainer: SharedContainerUserDefaults
    var analyticsRecorder: AnalyticsEventRecorderAPI

    var coincore: CoincoreAPI

    var walletManager: WalletManager
    var walletUpgradeService: WalletUpgradeServicing
    var exchangeRepository: ExchangeAccountRepositoryAPI

    var appFeatureConfigurator: FeatureConfiguratorAPI
    var blockchainSettings: BlockchainSettings.App
    var credentialsStore: CredentialsStoreAPI

    var urlSession: URLSession
    var mainQueue: AnySchedulerOf<DispatchQueue>
}
