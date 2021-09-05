// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import ComposableArchitecture
import DIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import SettingsKit
import WalletPayloadKit
import XCTest

@testable import Blockchain

// swiftlint:disable type_body_length
final class LoggedInReducerTests: XCTestCase {

    var mockWalletManager: WalletManager!
    var mockWallet: MockWallet! = MockWallet()
    var mockReactiveWallet = MockReactiveWallet()
    var mockSettingsApp: MockBlockchainSettingsApp!
    var mockAlertPresenter: MockAlertViewPresenter!
    var mockExchangeAccountRepository: MockExchangeAccountRepository!
    var mockRemoteNotificationAuthorizer: MockRemoteNotificationAuthorizer!
    var mockRemoteNotificationServiceContainer: MockRemoteNotificationServiceContainer!
    var mockCoincore: MockCoincore!
    var mockAnalyticsRecorder: MockAnalyticsRecorder!
    var onboardingSettings: MockOnboardingSettings!
    var mockAppDeeplinkHandler: MockAppDeeplinkHandler!
    var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    var mockDeepLinkRouter: MockDeepLinkRouter!
    var mockFeatureFlagsService: MockFeatureFlagsService!
    var fiatCurrencySettingsServiceMock: FiatCurrencySettingsServiceMock!

    var testStore: TestStore<
        LoggedIn.State,
        LoggedIn.State,
        LoggedIn.Action,
        LoggedIn.Action,
        LoggedIn.Environment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()

        mockSettingsApp = MockBlockchainSettingsApp()
        mockWalletManager = WalletManager(
            wallet: mockWallet,
            appSettings: mockSettingsApp,
            reactiveWallet: mockReactiveWallet
        )
        mockAlertPresenter = MockAlertViewPresenter()
        mockExchangeAccountRepository = MockExchangeAccountRepository()
        mockRemoteNotificationAuthorizer = MockRemoteNotificationAuthorizer(
            expectedAuthorizationStatus: UNAuthorizationStatus.authorized,
            authorizationRequestExpectedStatus: .success(())
        )
        mockRemoteNotificationServiceContainer = MockRemoteNotificationServiceContainer(
            authorizer: mockRemoteNotificationAuthorizer
        )
        mockCoincore = MockCoincore()
        mockAnalyticsRecorder = MockAnalyticsRecorder()
        onboardingSettings = MockOnboardingSettings()
        mockAppDeeplinkHandler = MockAppDeeplinkHandler()
        mockMainQueue = DispatchQueue.test
        mockDeepLinkRouter = MockDeepLinkRouter()
        mockFeatureFlagsService = MockFeatureFlagsService()
        fiatCurrencySettingsServiceMock = FiatCurrencySettingsServiceMock(expectedCurrency: .USD)

        testStore = TestStore(
            initialState: LoggedIn.State(),
            reducer: loggedInReducer,
            environment: LoggedIn.Environment(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                analyticsRecorder: mockAnalyticsRecorder,
                loadingViewPresenter: LoadingViewPresenter(),
                exchangeRepository: mockExchangeAccountRepository,
                remoteNotificationTokenSender: mockRemoteNotificationServiceContainer.tokenSender,
                remoteNotificationAuthorizer: mockRemoteNotificationServiceContainer.authorizer,
                walletManager: mockWalletManager,
                coincore: mockCoincore,
                appSettings: mockSettingsApp,
                deeplinkRouter: mockDeepLinkRouter,
                featureFlagsService: mockFeatureFlagsService,
                fiatCurrencySettingsService: fiatCurrencySettingsServiceMock
            )
        )
    }

    override func tearDownWithError() throws {
        mockSettingsApp = nil
        mockAlertPresenter = nil
        mockExchangeAccountRepository = nil
        mockRemoteNotificationAuthorizer = nil
        mockRemoteNotificationServiceContainer = nil
        mockCoincore = nil
        mockAnalyticsRecorder = nil
        onboardingSettings = nil
        mockAppDeeplinkHandler = nil
        mockMainQueue = nil
        mockDeepLinkRouter = nil
        mockFeatureFlagsService = nil
        fiatCurrencySettingsServiceMock = nil

        testStore = nil

        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = LoggedIn.State()
        XCTAssertNil(state.displayWalletAlertContent)
        XCTAssertFalse(state.reloadAfterMultiAddressResponse)
        XCTAssertFalse(state.reloadAfterSymbolChanged)
    }

    func test_calling_start_on_reducer_should_post_login_notification() {
        let expectation = self.expectation(forNotification: .login, object: nil)

        testStore.send(.start(.none))
        mockMainQueue.advance()

        wait(for: [expectation], timeout: 2)
        testStore.send(.logout)
    }

    func test_calling_start_calls_required_services() {
        testStore.send(.start(.none))
        mockMainQueue.advance()

        XCTAssertTrue(mockExchangeAccountRepository.syncDepositAddressesIfLinkedPublisherCalled)

        XCTAssertTrue(mockRemoteNotificationServiceContainer.sendTokenIfNeededPublisherCalled)

        XCTAssertTrue(mockRemoteNotificationAuthorizer.requestAuthorizationIfNeededPublisherCalled)

        XCTAssertTrue(mockCoincore.initializePublisherCalled)

        testStore.send(.logout)
    }

    func test_reducer_handles_new_wallet_correctly_should_show_new_onboarding() {
        // when
        _ = mockFeatureFlagsService.enable(.remote(.showOnboardingAfterSignUp))

        // given
        let context = LoggedIn.Context.wallet(.new)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.handleNewWalletCreation)

        testStore.receive(.showOnboarding) { state in
            state.displayOnboardingFlow = true
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_new_wallet_correctly_should_show_legacy_flow() {
        // when
        _ = mockFeatureFlagsService.disable(.remote(.showOnboardingAfterSignUp))

        // given
        let context = LoggedIn.Context.wallet(.new)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.handleNewWalletCreation)

        testStore.receive(.showLegacyBuyFlow) { state in
            state.displayLegacyBuyFlow = true
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_deeplink_sendCrypto_correctly() {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .sendCrypto)
        let context = LoggedIn.Context.deeplink(uriContent)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.deeplink(uriContent)) { state in
            state.displaySendCryptoScreen = true
        }

        testStore.receive(.deeplinkHandled) { state in
            state.displaySendCryptoScreen = false
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_deeplink_executeDeeplinkRouting_correctly() {
        let uriContent = URIContent(url: URL(string: "https://")!, context: .executeDeeplinkRouting)
        let context = LoggedIn.Context.deeplink(uriContent)
        testStore.send(.start(context))
        mockMainQueue.advance()

        // then
        testStore.receive(.deeplink(uriContent))

        XCTAssertTrue(mockDeepLinkRouter.routeIfNeededCalled)

        testStore.send(.logout)
    }

    func test_verify_start_action_observers_symbol_changes() {
        testStore.send(.start(.none))

        mockSettingsApp.symbolLocal = false
        mockSettingsApp.symbolLocal = true

        testStore.receive(.symbolChanged) { state in
            state.reloadAfterSymbolChanged = true
        }

        testStore.receive(.symbolChangedHandled) { state in
            state.reloadAfterSymbolChanged = false
        }

        testStore.send(.logout)
    }

    func test_verify_sending_wallet_accountInfoAndExchangeRates_updates_the_state() {
        testStore.send(.start(.none))

        testStore.send(.wallet(.accountInfoAndExchangeRates)) { state in
            state.reloadAfterMultiAddressResponse = true
        }

        testStore.receive(.wallet(.accountInfoAndExchangeRatesHandled)) { state in
            state.reloadAfterMultiAddressResponse = false
        }
        testStore.send(.logout)
    }

    func test_verify_sending_wallet_handleWalletBackup() {
        testStore.send(.start(.none))

        testStore.send(.wallet(.handleWalletBackup))

        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)

        testStore.send(.logout)
    }

    func test_verify_sending_wallet_handleFailToLoadHistory() {
        testStore.send(.start(.none))

        // when sending an non nil error
        testStore.send(.wallet(.handleFailToLoadHistory(nil))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
        }

        // when sending an non nil error
        let errorMessage = "this is an error message"
        testStore.send(.wallet(.handleFailToLoadHistory(errorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.balancesGeneric
            )
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_walletDidGetAccountInfoAndExchangeRates() {
        // given
        testStore.send(.start(.none))

        // when
        mockWallet.delegate.walletDidGetAccountInfoAndExchangeRates?(mockWallet)
        mockMainQueue.advance()

        // then
        testStore.receive(.wallet(.accountInfoAndExchangeRates)) { state in
            state.reloadAfterMultiAddressResponse = true
        }
        testStore.receive(.wallet(.accountInfoAndExchangeRatesHandled)) { state in
            state.reloadAfterMultiAddressResponse = false
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_walletBackupFailed() {
        // given
        testStore.send(.start(.none))

        // when
        mockWallet.delegate?.didBackupWallet?()
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)
        testStore.receive(.wallet(.handleWalletBackup))

        testStore.send(.logout)
    }

    func test_reducer_handles_walletBackupSuccess() {
        // given
        testStore.send(.start(.none))

        // when
        mockWallet.delegate?.didFailBackupWallet?()
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockWallet.getHistoryForAllAssetsCalled)
        testStore.receive(.wallet(.handleWalletBackup))

        testStore.send(.logout)
    }

    func test_reducer_handles_walletFailedToGetHistory_with_an_error_message() {
        // given
        testStore.send(.start(.none))

        // when
        let errorMessage = "an error message"
        mockWallet.delegate?.didFailGetHistory?(errorMessage)
        mockMainQueue.advance()

        // then
        XCTAssertTrue(mockAnalyticsRecorder.recordEventCalled.called)
        testStore.receive(.wallet(.handleFailToLoadHistory(errorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.balancesGeneric
            )
        }

        testStore.send(.logout)
    }

    func test_reducer_handles_walletFailedToGetHistory_with_an_empty_error_message() {
        // given
        testStore.send(.start(.none))

        // when
        let emptyErrorMessage = ""
        mockWallet.delegate?.didFailGetHistory?(emptyErrorMessage)
        mockMainQueue.advance()

        // then
        testStore.receive(.wallet(.handleFailToLoadHistory(emptyErrorMessage))) { state in
            state.displayWalletAlertContent = AlertViewContent(
                title: LocalizationConstants.Errors.error,
                message: LocalizationConstants.Errors.noInternetConnectionPleaseCheckNetwork
            )
        }

        testStore.send(.logout)
    }
}

// swiftlint:enable type_body_length
