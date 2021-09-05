// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import SwiftUI
@testable import TransactionUIKit
import XCTest

final class TransactionsRouterTests: XCTestCase {

    private var router: TransactionsRouter!
    private var mockLegacyBuyFlowPresenter: MockLegacyBuyFlowPresenter!
    private var mockCryptoCurrencyService: MockCryptoCurrenciesService!
    private var mockFeatureFlagsService: InternalFeatureFlagServiceMock!
    private var mockKYCService: MockKYCSDDService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockCryptoCurrencyService = MockCryptoCurrenciesService()
        mockFeatureFlagsService = InternalFeatureFlagServiceMock()
        mockKYCService = MockKYCSDDService()
        mockLegacyBuyFlowPresenter = MockLegacyBuyFlowPresenter(
            cryptoCurrenciesService: mockCryptoCurrencyService,
            kycService: mockKYCService
        )
        router = TransactionsRouter(
            featureFlagsService: mockFeatureFlagsService,
            legacyBuyPresenter: mockLegacyBuyFlowPresenter
        )
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        router = nil
        mockKYCService = nil
        mockFeatureFlagsService = nil
        mockCryptoCurrencyService = nil
        mockLegacyBuyFlowPresenter = nil
    }

    func test_routesTo_legacyBuyFlow_forCryptoAccount_featueFlagOff() throws {
        throw XCTSkip("This test crashes due to DIKit. It will require more mocks. Will do later.")
        mockFeatureFlagsService.disable(.useTransactionsFlowToBuyCrypto)
        let mockViewController = MockViewController()
        let cryptoAccount = CryptoInterestAccount(asset: .coin(.bitcoin))
        let cancellable = router.presentTransactionFlow(to: .buy(cryptoAccount), from: mockViewController)
            .sink { _ in
                // no-op
            }

        let recordedInvocations = mockLegacyBuyFlowPresenter.recordedInvocations
        XCTAssertEqual(recordedInvocations.presentBuyScreen, 1)
        cancellable.cancel()
    }

    func test_routesTo_legacyBuyFlow_nilAccount_featueFlagOff() throws {
        mockFeatureFlagsService.disable(.useTransactionsFlowToBuyCrypto)
        let mockViewController = MockViewController()
        let cancellable = router.presentTransactionFlow(to: .buy(nil), from: mockViewController)
            .sink { _ in
                // no-op
            }

        let recordedInvocations = mockLegacyBuyFlowPresenter.recordedInvocations
        XCTAssertEqual(recordedInvocations.presentBuyFlowWithTargetCurrencySelectionIfNecessary, 1)
        cancellable.cancel()
    }

    func test_routesTo_legacyBuyFlow_featueFlagOn() throws {
        throw XCTSkip("This test crashes due to DIKit. It will require more mocks and refactoring. Will do later.")
        mockFeatureFlagsService.enable(.useTransactionsFlowToBuyCrypto)
        let mockViewController = MockViewController()
        let cancellable = router.presentTransactionFlow(to: .buy(nil), from: mockViewController)
            .sink { _ in
                // no-op
            }

        // TODO: IOS-4879 update this as concrete implementation gets built...
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        XCTAssertEqual(presentedViewController?.view.backgroundColor, .red)
        cancellable.cancel()
    }
}

final class MockLegacyBuyFlowPresenter: LegacyBuyFlowPresenter {

    struct RecordedInvocations {
        var presentBuyScreen: Int = 0
        var presentBuyFlowWithTargetCurrencySelectionIfNecessary: Int = 0
    }

    private(set) var recordedInvocations = RecordedInvocations()

    override func presentBuyScreen(
        from presenter: UIViewController,
        targetCurrency: CryptoCurrency,
        sourceCurrency: FiatCurrency,
        isSDDEligible: Bool = true
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        recordedInvocations.presentBuyScreen += 1
        return .empty()
    }

    override func presentBuyFlowWithTargetCurrencySelectionIfNecessary(
        from presenter: UIViewController,
        using fiatCurrency: FiatCurrency
    ) -> AnyPublisher<TransactionFlowResult, Never> {
        recordedInvocations.presentBuyFlowWithTargetCurrencySelectionIfNecessary += 1
        return .empty()
    }
}
