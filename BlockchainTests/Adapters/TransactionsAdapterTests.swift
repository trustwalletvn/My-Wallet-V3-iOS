// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import Blockchain
import Combine
import FeatureOnboardingUI
import FeatureTransactionUI
import ToolKit
import XCTest

final class TransactionsAdapterTests: XCTestCase {

    private var adapter: TransactionsAdapter!
    private var mockTransactionsRouter: MockTransactionsRouter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockTransactionsRouter = MockTransactionsRouter()
        adapter = TransactionsAdapter(router: mockTransactionsRouter)
    }

    override func tearDownWithError() throws {
        adapter = nil
        mockTransactionsRouter = nil
        try super.tearDownWithError()
    }

    // MARK: - FeatureOnboardingUI.BuyCryptoRouterAPI

    func test_routesTo_buyFlow_for_onboarding() throws {
        // WHEN: The adapter is asked to present the buy flow
        let presenter = UIViewController()
        let _: AnyPublisher<OnboardingResult, Never> = adapter.presentBuyFlow(from: presenter)
        // THEN: It delegates to the Transaction's module router to do that
        XCTAssertEqual(mockTransactionsRouter.recordedInvocations.presentTransactionFlow.count, 1)
        XCTAssertEqual(mockTransactionsRouter.recordedInvocations.presentTransactionFlow.first?.presenter, presenter)
        XCTAssertEqual(mockTransactionsRouter.recordedInvocations.presentTransactionFlow.first?.action, .buy(nil))
    }

    func test_converts_abandoned_result_for_onboarding() throws {
        // GIVEN: The flow completes with the user having abandoned it
        mockTransactionsRouter.stubbedResults.presentTransactionFlow = .just(.abandoned)
        // WHEN: The adapter is asked to present the buy flow
        let publisher: AnyPublisher<OnboardingResult, Never> = adapter.presentBuyFlow(from: UIViewController())
        // THEN: The returned publisher completes with the corresponding result
        var result: OnboardingResult?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { onboardingResult in
            result = onboardingResult
            e.fulfill()
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(result, .abandoned)
    }

    func test_converts_completed_result_for_onboarding() throws {
        // GIVEN: The buy flow completes with the user having abandoned it
        mockTransactionsRouter.stubbedResults.presentTransactionFlow = .just(.completed)
        // WHEN: The adapter is asked to present the buy flow
        let publisher: AnyPublisher<OnboardingResult, Never> = adapter.presentBuyFlow(from: UIViewController())
        // THEN: The returned publisher completes with the corresponding result
        var result: OnboardingResult?
        let e = expectation(description: "Wait for publisher to complete")
        let cancellable = publisher.sink { onboardingResult in
            result = onboardingResult
            e.fulfill()
        }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(result, .completed)
    }
}

final class MockTransactionsRouter: FeatureTransactionUI.TransactionsRouterAPI {

    struct RecordedInvocations {
        var presentTransactionFlow: [(action: TransactionFlowAction, presenter: UIViewController)] = []
    }

    struct StubbedResults {
        var presentTransactionFlow: AnyPublisher<TransactionFlowResult, Never> = .just(.abandoned)
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func presentTransactionFlow(to action: TransactionFlowAction, from presenter: UIViewController) -> AnyPublisher<TransactionFlowResult, Never> {
        recordedInvocations.presentTransactionFlow.append((action, presenter))
        return stubbedResults.presentTransactionFlow
    }
}
