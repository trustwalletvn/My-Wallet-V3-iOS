// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import ComposableArchitecture
@testable import FeatureAuthenticationDomain
@testable import FeatureAuthenticationUI
import Localization
import ToolKit
import XCTest

// Mocks
@testable import AnalyticsKitMock
@testable import FeatureAuthenticationMock
@testable import ToolKitMock

final class VerifyDeviceReducerTests: XCTestCase {

    private var mockMainQueue: TestSchedulerOf<DispatchQueue>!
    private var testStore: TestStore<
        VerifyDeviceState,
        VerifyDeviceState,
        VerifyDeviceAction,
        VerifyDeviceAction,
        VerifyDeviceEnvironment
    >!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockMainQueue = DispatchQueue.test
        testStore = TestStore(
            initialState: .init(emailAddress: ""),
            reducer: verifyDeviceReducer,
            environment: .init(
                mainQueue: mockMainQueue.eraseToAnyScheduler(),
                deviceVerificationService: MockDeviceVerificationService(),
                errorRecorder: NoOpErrorRecorder(),
                externalAppOpener: MockExternalAppOpener(),
                analyticsRecorder: MockAnalyticsRecorder()
            )
        )
    }

    override func tearDownWithError() throws {
        mockMainQueue = nil
        testStore = nil
        try super.tearDownWithError()
    }

    func test_verify_initial_state_is_correct() {
        let state = VerifyDeviceState(emailAddress: "")
        XCTAssertNil(state.credentialsState)
        XCTAssertEqual(state.credentialsContext, .none)
        XCTAssertFalse(state.isCredentialsScreenVisible)
    }

    func test_receive_valid_wallet_deeplink_should_update_wallet_info() {
        testStore.assert(
            .send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.validDeeplink)),
            .do { self.mockMainQueue.advance() },
            .receive(.didExtractWalletInfo(MockDeviceVerificationService.mockWalletInfo)) { state in
                state.credentialsContext = .walletInfo(MockDeviceVerificationService.mockWalletInfo)
            },
            .receive(.setCredentialsScreenVisible(true)) { state in
                state.credentialsState = .init()
                state.isCredentialsScreenVisible = true
            }
        )
    }

    func test_deeplink_parsing_failure_should_fallback_to_wallet_identifier() {
        testStore.send(.didReceiveWalletInfoDeeplink(MockDeviceVerificationService.invalidDeeplink))
        mockMainQueue.advance()

        testStore.receive(.fallbackToWalletIdentifier) { state in
            state.credentialsContext = .walletIdentifier(email: "")
        }

        testStore.receive(.setCredentialsScreenVisible(true)) { state in
            state.credentialsState = .init()
            state.isCredentialsScreenVisible = true
        }
    }
}
