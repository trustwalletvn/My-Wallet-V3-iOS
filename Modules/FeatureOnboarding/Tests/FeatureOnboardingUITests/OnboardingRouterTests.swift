// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import FeatureOnboardingUI
@testable import PlatformUIKitMock
import TestKit
import ToolKit
@testable import ToolKitMock
import XCTest

final class OnboardingRouterTests: XCTestCase {

    private var router: OnboardingRouter!
    private var mockBuyCryptoRouter: MockBuyCryptoRouter!
    private var mockFeatureFlagService: MockFeatureFlagsService!
    private var mockEmailVerificationRouter: MockOnboardingEmailVerificationRouter!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockBuyCryptoRouter = MockBuyCryptoRouter()
        mockFeatureFlagService = MockFeatureFlagsService()
        mockEmailVerificationRouter = MockOnboardingEmailVerificationRouter()
        router = OnboardingRouter(
            buyCryptoRouter: mockBuyCryptoRouter,
            emailVerificationRouter: mockEmailVerificationRouter,
            featureFlagsService: mockFeatureFlagService
        )
    }

    override func tearDownWithError() throws {
        router = nil
        mockBuyCryptoRouter = nil
        mockFeatureFlagService = nil
        mockEmailVerificationRouter = nil
        try super.tearDownWithError()
    }

    func test_skipsEmailVerification_if_feature_is_disabled() throws {
        let featureFlagPublisher = mockFeatureFlagService.disable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)
        let routingResultPublisher = router.presentOnboarding(from: UIViewController())
        XCTAssertPublisherCompletion(routingResultPublisher)
        XCTAssertEqual(mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.count, 0)
    }

    func test_routesToEmailVerification_if_feature_is_enabled() throws {
        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)
        let routingResultPublisher = router.presentOnboarding(from: UIViewController())
        XCTAssertPublisherCompletion(routingResultPublisher)
        XCTAssertEqual(mockEmailVerificationRouter.recordedInvocations.presentEmailVerification.count, 1)
    }

    func test_completesOnboarding_when_emailVerifcation_is_abandoned() throws {
        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
        XCTAssertPublisherCompletion(featureFlagPublisher)
        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = .just(.abandoned)
        let mockViewController = MockViewController()

        var onboardingResult: OnboardingResult?
        let e = expectation(description: "Wait for email verification completion")
        let cancellable = router.presentOnboarding(from: mockViewController)
            .sink { result in
                onboardingResult = result
                e.fulfill()
            }
        wait(for: [e], timeout: 5)
        cancellable.cancel()
        XCTAssertEqual(onboardingResult, .abandoned)
        XCTAssertEqual(mockBuyCryptoRouter.recordedInvocations.presentBuyFlow.count, 0)
    }

    // IOS-5189
//    func test_dismissesEmailVerification_when_emailVerifcation_is_complete() throws {
//        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
//        XCTAssertPublisherCompletion(featureFlagPublisher)
//        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = .just(.completed)
//        let mockViewController = MockViewController()
//
//        let e = expectation(description: "Wait for email verification completion")
//        let cancellable = router.presentOnboarding(from: mockViewController)
//            .sink { _ in
//                e.fulfill()
//            }
//
//        let delay = expectation(description: "Wait for flat map")
//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: delay.fulfill)
//        wait(for: [delay], timeout: 5)
//
//        let dismissalRequests = mockViewController.recordedInvocations.dismiss
//        dismissalRequests.first?.completion?()
//        XCTAssertEqual(dismissalRequests.count, 1)
//
//        wait(for: [e], timeout: 5)
//        cancellable.cancel()
//    }
//
//    func test_presents_buyFlow_after_emailVerification() throws {
//        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
//        XCTAssertPublisherCompletion(featureFlagPublisher)
//        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = .just(.completed)
//        let mockViewController = MockViewController()
//
//        var onboardingResult: OnboardingResult?
//        let e = expectation(description: "Wait for email verification completion")
//        let cancellable = router.presentOnboarding(from: mockViewController)
//            .sink { result in
//                onboardingResult = result
//                e.fulfill()
//            }
//
//        let delay = expectation(description: "Wait for flat map")
//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: delay.fulfill)
//        wait(for: [delay], timeout: 5)
//
//        let dismissalRequests = mockViewController.recordedInvocations.dismiss
//        dismissalRequests.first?.completion?()
//        XCTAssertEqual(dismissalRequests.count, 1)
//
//        wait(for: [e], timeout: 5)
//        cancellable.cancel()
//        XCTAssertEqual(mockBuyCryptoRouter.recordedInvocations.presentBuyFlow.count, 1)
//        XCTAssertEqual(onboardingResult, .abandoned)
//    }
//
//    func test_completes_when_buyFlow_is_complete() throws {
//        let featureFlagPublisher = mockFeatureFlagService.enable(.remote(.showEmailVerificationInOnboarding))
//        XCTAssertPublisherCompletion(featureFlagPublisher)
//        mockEmailVerificationRouter.stubbedResults.presentEmailVerification = .just(.completed)
//        mockBuyCryptoRouter.stubbedResults.presentBuyFlow = .just(.completed)
//        let mockViewController = MockViewController()
//
//        var onboardingResult: OnboardingResult?
//        let e = expectation(description: "Wait for email verification completion")
//        let cancellable = router.presentOnboarding(from: mockViewController)
//            .sink { result in
//                onboardingResult = result
//                e.fulfill()
//            }
//
//        let delay = expectation(description: "Wait for flat map")
//        DispatchQueue.main.asyncAfter(deadline: .now(), execute: delay.fulfill)
//        wait(for: [delay], timeout: 5)
//
//        let dismissalRequests = mockViewController.recordedInvocations.dismiss
//        dismissalRequests.first?.completion?()
//        XCTAssertEqual(dismissalRequests.count, 1)
//
//        wait(for: [e], timeout: 5)
//        cancellable.cancel()
//        XCTAssertEqual(mockBuyCryptoRouter.recordedInvocations.presentBuyFlow.count, 1)
//        XCTAssertEqual(onboardingResult, .completed)
//    }
}
