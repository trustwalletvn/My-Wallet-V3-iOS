// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import FeatureSettingsDomain
import PlatformKit
import PlatformUIKit
import RxSwift
import WalletPayloadKit
import XCTest

@testable import Blockchain
@testable import FeatureAuthenticationUI

// swiftlint:disable type_body_length
final class MainAppReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet! = MockWallet()
    var mockReactiveWallet = MockReactiveWallet()
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockCredentialsStore: CredentialsStoreAPIMock!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockWalletUpgradeService: MockWalletUpgradeService!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer: MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockCoincore: MockCoincore!
    var mockFeatureConfigurator: MockFeatureConfigurator!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var mockSiftService: MockSiftService!
    var onboardingSettings: MockOnboardingSettings!
    var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    var mockDeepLinkHandler: MockDeepLinkHandler!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var mockFeatureFlagsService: MockFeatureFlagsService!
    var mockInternalFeatureFlagService: InternalFeatureFlagServiceMock!
    var mockFiatCurrencySettingsService: FiatCurrencySettingsServiceMock!

    var testStore: TestStore<
        CoreAppState,
        CoreAppState,
        CoreAppAction,
        CoreAppAction,
        CoreAppEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockSettingsApp = MockBlockchainSettingsApp()
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: mockSettingsApp,
            reactiveWallet: mockReactiveWallet
        )
        mockCredentialsStore = CredentialsStoreAPIMock()
        mockAlertPresenter = MockAlertViewPresenter()
        mockWalletUpgradeService = MockWalletUpgradeService()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockCoincore = MockCoincore()
        mockFeatureConfigurator = MockFeatureConfigurator()
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        mockSiftService = MockSiftService()
        onboardingSettings = MockOnboardingSettings()
        mockMainQueue = DispatchQueue.test
        mockDeepLinkHandler = MockDeepLinkHandler()
        mockDeepLinkRouter = MockDeepLinkRouter()
        mockFeatureFlagsService = MockFeatureFlagsService()
        mockInternalFeatureFlagService = InternalFeatureFlagServiceMock()
        mockFiatCurrencySettingsService = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)

        testStore = TestStore(
            initialState: CoreAppState(),
            reducer: mainAppReducer,
            environment: CoreAppEnvironment(
                loadingViewPresenter: LoadingViewPresenter(),
                deeplinkHandler: mockDeepLinkHandler,
                deeplinkRouter: mockDeepLinkRouter,
                walletManager: mockWalletManager,
                featureFlagsService: mockFeatureFlagsService,
                appFeatureConfigurator: mockFeatureConfigurator,
                internalFeatureService: mockInternalFeatureFlagService,
                fiatCurrencySettingsService: mockFiatCurrencySettingsService,
                blockchainSettings: mockSettingsApp,
                credentialsStore: mockCredentialsStore,
                alertPresenter: mockAlertPresenter,
                walletUpgradeService: mockWalletUpgradeService,
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationServiceContainer: mockRemoteNotificationServiceContainer,
                coincore: mockCoincore,
                sharedContainer: SharedContainerUserDefaults(),
                analyticsRecorder: mockAnalyticsRecorder,
                siftService: mockSiftService,
                onboardingSettings: onboardingSettings,
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                buildVersionProvider: { "" }
            )
        )
    }

    override func tearDownWithError() throws {
        mockSettingsApp = nil
        mockWalletManager = nil
        mockCredentialsStore = nil
        mockAlertPresenter = nil
        mockWalletUpgradeService = nil
        mockExchangeAccountRepository = nil
        mockRemoteNotificationAuthorizer = nil
        mockRemoteNotificationServiceContainer = nil
        mockCoincore = nil
        mockFeatureConfigurator = nil
        mockAnalyticsRecorder = nil
        mockSiftService = nil
        onboardingSettings = nil
        mockMainQueue = nil
        mockDeepLinkHandler = nil
        mockDeepLinkRouter = nil
        mockFeatureFlagsService = nil
        mockInternalFeatureFlagService = nil
        mockFiatCurrencySettingsService = nil

        testStore = nil

        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = CoreAppState()
        XCTAssertNotNil(state.onboarding)
        XCTAssertNil(state.loggedIn)
    }

    func test_syncPinKeyWithICloud() {
        // given
        mockSettingsApp.isPairedWithWallet = true

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.guid = "a"
        mockSettingsApp.sharedKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.encryptedPinPassword = "a"
        mockSettingsApp.pinKey = "b"

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertFalse(mockCredentialsStore.synchronizeCalled)

        // given
        mockSettingsApp.isPairedWithWallet = false
        mockSettingsApp.pinKey = nil
        mockSettingsApp.encryptedPinPassword = nil
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil

        // method is implementing fireAndForget
        syncPinKeyWithICloud(
            blockchainSettings: mockSettingsApp,
            credentialsStore: mockCredentialsStore
        )

        XCTAssertTrue(mockCredentialsStore.synchronizeCalled)
        XCTAssertTrue(mockCredentialsStore.expectedPinDataCalled)
    }

    func test_sending_start_should_correct_outputs() {
        testStore.send(.start) { state in
            state.onboarding = Onboarding.State()
            state.loggedIn = nil
        }
        XCTAssertTrue(mockFeatureConfigurator.initializeCalled)
    }

    func test_verify_didDecryptWallet_action_updates_appSettings() {
        testStore.send(
            .didDecryptWallet(.init(guid: "a", sharedKey: "b", passwordPartHash: "c"))
        )
        XCTAssertNotNil(testStore.environment.blockchainSettings.guid)
        XCTAssertEqual(testStore.environment.blockchainSettings.guid, "a")

        XCTAssertNotNil(testStore.environment.blockchainSettings.sharedKey)
        XCTAssertEqual(testStore.environment.blockchainSettings.sharedKey, "b")
    }

    func test_trying_to_login_withSecondPassword_account_displays_notice() {
        mockWallet.mockNeedsSecondPassword = true
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil
        mockSettingsApp.isPinSet = false

        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.welcomeState = .init()
        }

        testStore.receive(.onboarding(.welcomeScreen(.start))) { state in
            state.onboarding?.welcomeState?.manualPairingEnabled = true
        }
        testStore.send(.onboarding(.welcomeScreen(.presentScreenFlow(.manualLoginScreen)))) { state in
            state.onboarding?.welcomeState?.screenFlow = .manualLoginScreen
            state.onboarding?.welcomeState?.manualCredentialsState = .init()
        }
        testStore.send(
            .onboarding(
                .welcomeScreen(
                    .manualPairing(
                        .walletPairing(
                            .decryptWalletWithPassword("password")
                        )
                    )
                )
            )
        ) { state in
            state.onboarding?.welcomeState?.manualCredentialsState?.isLoading = true
        }

        testStore.receive(.onboarding(.welcomeScreen(.requestedToDecryptWallet("password"))))
        testStore.receive(.fetchWallet("password"))
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )
        testStore.receive(.authenticate)
        mockMainQueue.advance()

        // wallet decryptions still expects the original values
        let decryption = WalletDecryption(
            guid: String(repeating: "a", count: 36),
            sharedKey: String(repeating: "b", count: 36),
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.authenticated(.success(true)))

        // Assert that both of these values are nil
        XCTAssertNil(mockSettingsApp.guid)
        XCTAssertNil(mockSettingsApp.sharedKey)

        testStore.receive(.onboarding(.informSecondPasswordDetected))
        testStore.receive(.onboarding(.welcomeScreen(.informSecondPasswordDetected))) { state in
            state.onboarding?.welcomeState?.screenFlow = .welcomeScreen
            state.onboarding?.welcomeState?.modals = .secondPasswordNoticeScreen
            state.onboarding?.welcomeState?.secondPasswordNoticeState = .init()
        }
    }

    func test_sending_success_authentication_from_password_required_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = false
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.passwordScreen = .init()
        }

        // password screen should start
        testStore.receive(.onboarding(.passwordScreen(.start)))

        // when authenticating
        testStore.send(.onboarding(.passwordScreen(.authenticate("password"))))

        testStore.receive(.fetchWallet("password"))
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )
        testStore.receive(.authenticate)
        mockMainQueue.advance()

        let decryption = WalletDecryption(
            guid: mockSettingsApp.guid,
            sharedKey: mockSettingsApp.sharedKey,
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.authenticated(.success(true)))
        testStore.receive(.setupPin) { state in
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordScreen = nil
        }
        testStore.receive(.onboarding(.pin(.create))) { state in
            state.onboarding?.pinState?.creating = true
        }
    }

    func test_sending_success_authentication_from_pin() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordScreen = nil
        }

        // password screen should start
        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
        }

        // when authenticating
        testStore.send(.onboarding(.pin(.handleAuthentication("password"))))

        testStore.receive(.fetchWallet("password"))
        XCTAssertTrue(mockWallet.fetchCalled)
        mockWallet.load(
            withGuid: mockSettingsApp.guid!,
            sharedKey: mockSettingsApp.sharedKey!,
            password: "password".passwordPartHash
        )

        testStore.receive(.authenticate)
        mockMainQueue.advance()

        let decryption = WalletDecryption(
            guid: mockSettingsApp.guid,
            sharedKey: mockSettingsApp.sharedKey,
            passwordPartHash: nil
        )
        testStore.receive(.didDecryptWallet(decryption))
        testStore.receive(.authenticated(.success(true)))
        testStore.receive(.initializeWallet)
        mockReactiveWallet.mockState.on(.next(.initialized))
        mockMainQueue.advance()
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(false))
        testStore.receive(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.proceedToLoggedIn) { state in
            state.onboarding = nil
            state.loggedIn = .init()
        }
        let context = LoggedIn.Context.none
        testStore.receive(.loggedIn(.start(context)))
        mockMainQueue.advance()
        // send logout to clear pending effects after logged in.
        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.passwordScreen = .init()
        }
        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_creating_wallet() {
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil
        mockSettingsApp.isPinSet = false
        mockInternalFeatureFlagService.enable(.disableGUIDLogin)

        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.welcomeState = .init()
        }

        testStore.receive(.onboarding(.welcomeScreen(.start)))

        testStore.send(.onboarding(.welcomeScreen(.presentScreenFlow(.createWalletScreen)))) { state in
            state.onboarding?.welcomeState?.screenFlow = .createWalletScreen
            state.onboarding?.walletCreationContext = .new
            state.onboarding?.showLegacyCreateWalletScreen = true
        }

        testStore.receive(.authenticate)

        let guid = String(repeating: "a", count: 36)
        let sharedKey = String(repeating: "b", count: 36)
        // we need to assign this here as the WalletManager+Rx gets the password hash the legacy password
        mockWalletManager.legacyRepository.legacyPassword = "a-password"
        mockWallet.load(withGuid: guid, sharedKey: sharedKey, password: "a-password")

        mockMainQueue.advance()

        let walletDecryption = WalletDecryption(
            guid: guid,
            sharedKey: sharedKey,
            passwordPartHash: "a-password".passwordPartHash
        )
        testStore.receive(.didDecryptWallet(walletDecryption))
        testStore.receive(.authenticated(.success(true))) { state in
            state.onboarding?.showLegacyCreateWalletScreen = false
            state.onboarding?.welcomeState?.screenFlow = .createWalletScreen
        }
        testStore.receive(.onboarding(.welcomeScreen(.presentScreenFlow(.welcomeScreen)))) { state in
            state.onboarding?.welcomeState?.screenFlow = .welcomeScreen
        }
        testStore.receive(.setupPin) { state in
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordScreen = nil
        }
        testStore.receive(.onboarding(.pin(.create))) { state in
            state.onboarding?.pinState?.creating = true
        }
    }

    func test_recover_wallet() {
        mockSettingsApp.guid = nil
        mockSettingsApp.sharedKey = nil
        mockSettingsApp.isPinSet = false
        mockInternalFeatureFlagService.enable(.disableGUIDLogin)

        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.welcomeState = .init()
        }

        testStore.receive(.onboarding(.welcomeScreen(.start)))

        testStore.send(.onboarding(.welcomeScreen(.presentScreenFlow(.restoreWalletScreen)))) { state in
            state.onboarding?.welcomeState?.restoreWalletState = .init()
            state.onboarding?.welcomeState?.screenFlow = .restoreWalletScreen
            state.onboarding?.walletCreationContext = .recovery
            state.onboarding?.showLegacyRecoverWalletScreen = true
        }

        testStore.receive(.authenticate)

        let guid = String(repeating: "a", count: 36)
        let sharedKey = String(repeating: "b", count: 36)
        // we need to assign this here as the WalletManager+Rx gets the password hash the legacy password
        mockWalletManager.legacyRepository.legacyPassword = "a-password"
        mockWallet.load(withGuid: guid, sharedKey: sharedKey, password: "a-password")

        mockMainQueue.advance()

        let walletDecryption = WalletDecryption(
            guid: guid,
            sharedKey: sharedKey,
            passwordPartHash: "a-password".passwordPartHash
        )
        testStore.receive(.didDecryptWallet(walletDecryption))
        testStore.receive(.authenticated(.success(true))) { state in
            state.onboarding?.showLegacyRecoverWalletScreen = false
            state.onboarding?.welcomeState?.screenFlow = .restoreWalletScreen
        }
        testStore.receive(.onboarding(.welcomeScreen(.presentScreenFlow(.welcomeScreen)))) { state in
            state.onboarding?.welcomeState?.restoreWalletState = nil
            state.onboarding?.welcomeState?.screenFlow = .welcomeScreen
        }
        testStore.receive(.setupPin) { state in
            state.onboarding?.pinState = .init()
            state.onboarding?.passwordScreen = nil
        }
        testStore.receive(.onboarding(.pin(.create))) { state in
            state.onboarding?.pinState?.creating = true
        }
    }

    func test_sending_logout_should_perform_cleanup_and_display_password_screen() {
        testStore.send(.proceedToLoggedIn) { state in
            state.loggedIn = .init()
            state.onboarding = nil
        }
        mockMainQueue.advance()

        testStore.receive(.loggedIn(.start(.none)))
        mockMainQueue.advance()

        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        }

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(
            mockAnalyticsRecorder.recordEventCalled.event!.name,
            AnalyticsEvents.New.Navigation.signedOut.name
        )

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)
        XCTAssertTrue(onboardingSettings.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_logout_should_perform_cleanup_and_pin_screen() {
        // given valid parameters
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true
        testStore.send(.onboarding(.start)) { state in
            state.onboarding = .init()
            state.onboarding?.passwordScreen = nil
        }

        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
            state.onboarding?.passwordScreen = nil
        }

        testStore.send(.onboarding(.pin(.logout))) { state in
            state.loggedIn = nil
            state.onboarding = .init(pinState: nil, walletUpgradeState: nil, passwordScreen: .init())
        }

        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        XCTAssertNotNil(mockAnalyticsRecorder.recordEventCalled.event)
        XCTAssertEqual(
            mockAnalyticsRecorder.recordEventCalled.event!.name,
            AnalyticsEvents.New.Navigation.signedOut.name
        )

        XCTAssertTrue(mockSiftService.removeUserIdCalled)
        XCTAssertTrue(mockSettingsApp.resetCalled)
        XCTAssertTrue(onboardingSettings.resetCalled)

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_walletInitialized_should_check_if_wallet_upgrade_is_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(true))

        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.walletNeedsUpgrade(true)) { state in
            state.onboarding?.pinState = nil
            state.onboarding?.walletUpgradeState = WalletUpgrade.State()
            state.loggedIn = nil
        }

        testStore.receive(.onboarding(.walletUpgrade(.begin)))

        testStore.send(.onboarding(.walletUpgrade(.completed)))
        mockMainQueue.advance()
        testStore.receive(.proceedToLoggedIn) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        testStore.receive(.loggedIn(.start(.none)))

        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.passwordScreen = .init()
        }

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_walletInitialized_should_proceed_to_logged_in_when_no_upgrade_needed() {
        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(false))
        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.proceedToLoggedIn) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        testStore.receive(.loggedIn(.start(.none)))

        testStore.send(.loggedIn(.logout)) { state in
            state.loggedIn = nil
            state.onboarding = .init()
            state.onboarding?.pinState = nil
            state.onboarding?.passwordScreen = .init()
        }

        testStore.receive(.onboarding(.passwordScreen(.start)))
    }

    func test_sending_appForegrounded_while_wallet_not_initialized_and_logged_in_state() {
        // given
        mockSettingsApp.guid = String(repeating: "a", count: 36)
        mockSettingsApp.sharedKey = String(repeating: "b", count: 36)
        mockSettingsApp.isPinSet = true

        mockWalletUpgradeService.needsWalletUpgradeRelay.on(.next(false))
        testStore.send(.walletInitialized)
        mockMainQueue.advance()
        testStore.receive(.walletNeedsUpgrade(false))
        testStore.receive(.proceedToLoggedIn) { state in
            state.loggedIn = LoggedIn.State()
            state.onboarding = nil
        }
        testStore.receive(.loggedIn(.start(.none)))

        // when
        mockWallet.mockIsInitialized = false
        testStore.send(.appForegrounded)

        // then

        testStore.receive(.loggedIn(.stop))
        testStore.receive(.requirePin) { state in
            state.loggedIn = nil
            state.onboarding = .init()
        }
        testStore.receive(.onboarding(.start)) { state in
            state.onboarding?.pinState = .init()
        }
        testStore.receive(.onboarding(.pin(.authenticate))) { state in
            state.onboarding?.pinState?.authenticate = true
        }
    }

    func test_clearPinIfNeeded_correctly_clears_pin() {
        // given a hashed password
        mockSettingsApp.passwordPartHash = "a-hash"

        // 1. when the same password hash is used
        clearPinIfNeeded(for: "a-hash", appSettings: mockSettingsApp)

        // 1. then it should not clear the saved pin
        XCTAssertFalse(mockSettingsApp.clearPinCalled)

        // 2. when a different password hash is used (on password change)
        clearPinIfNeeded(for: "a-diff-hash", appSettings: mockSettingsApp)

        // 1. then it should clear the saved pin
        XCTAssertTrue(mockSettingsApp.clearPinCalled)
    }

    func test_wallet_decryption_outputs_decryption_failure_on_invalid_guid() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid guid
        let decryption = WalletDecryption(
            guid: "a",
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.errorDecryptingWallet,
            description: LocalizationConstants.Authentication.errorDecryptingWallet
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_failure_on_invalid_sharedKey() {
        // note: the count of a guid and shared key should equal to 36
        // given a non valid sharedKey
        let guid = String(repeating: "a", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: "b",
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        let expectedError = AuthenticationError(
            code: AuthenticationError.ErrorCode.invalidSharedKey,
            description: LocalizationConstants.Authentication.invalidSharedKey
        )

        XCTAssertEqual(CoreAppAction.decryptionFailure(expectedError), action)
    }

    func test_wallet_decryption_outputs_success_on_valid_creds() {
        // note: the count of a guid and shared key should equal to 36
        // given a valid guid
        let guid = String(repeating: "a", count: 36)
        let sharedKey = String(repeating: "b", count: 36)
        let decryption = WalletDecryption(
            guid: guid,
            sharedKey: sharedKey,
            passwordPartHash: "hashed"
        )

        // when
        let action = handleWalletDecryption(decryption)

        // then
        XCTAssertEqual(CoreAppAction.didDecryptWallet(decryption), action)
    }
}

// swiftlint:enable type_body_length
