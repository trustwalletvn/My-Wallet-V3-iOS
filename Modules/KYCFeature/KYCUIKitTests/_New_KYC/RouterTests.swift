// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import ComposableArchitecture
@testable import KYCUIKit
import PlatformUIKit
import SwiftUI
import TestKit
import XCTest

final class RouterTests: XCTestCase {

    private var router: KYCUIKit.Router!
    private var mockExternalAppOpener: MockExternalAppOpener!
    private var mockEmailVerificationService: MockEmailVerificationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockExternalAppOpener = MockExternalAppOpener()
        mockEmailVerificationService = MockEmailVerificationService()
        router = .init(
            analyticsRecorder: MockAnalyticsRecorder(),
            legacyRouter: MockLegacyKYCRouter(),
            kycService: MockKYCTiersService(),
            emailVerificationService: mockEmailVerificationService,
            openMailApp: mockExternalAppOpener.openMailApp
        )
    }

    override func tearDownWithError() throws {
        router = nil
        mockExternalAppOpener = nil
        mockEmailVerificationService = nil
        try super.tearDownWithError()
    }

    func test_routesTo_emailVerification() throws {
        let viewController = MockViewController()
        router.routeToEmailVerification(from: viewController, emailAddress: "test@example.com", flowCompletion: { _ in })
        let presentedViewController = viewController.recordedInvocations.presentViewController.first
        XCTAssertNotNil(presentedViewController as? UIHostingController<EmailVerificationView>)
    }

    func test_calls_back_to_passedIn_completionBlock() throws {
        var didCallCompletionBlock = false
        let environment = router.buildEmailVerificationEnvironment(emailAddress: "test@example.com", flowCompletion: { _ in
            didCallCompletionBlock = true
        })
        environment.flowCompletionCallback?(.completed)
        XCTAssertTrue(didCallCompletionBlock)
    }

    func test_uses_extenalAppOpener_to_openMailApp() throws {
        let environment = router.buildEmailVerificationEnvironment(emailAddress: "test@example.com", flowCompletion: { _ in })
        var valueReceived = false
        let e = expectation(description: "Wait for publisher to send value")
        let cancellable = environment.openMailApp()
            .sink(receiveValue: { value in
                valueReceived = value
                e.fulfill()
            })
        let openMailRequest = mockExternalAppOpener.recordedInvocations.open.first
        XCTAssertEqual(openMailRequest?.url, URL(string: "message://"))
        if let completionHandler = openMailRequest?.completionHandler {
            completionHandler(true)
        }
        waitForExpectations(timeout: 3)
        XCTAssertTrue(valueReceived)
        cancellable.cancel()
    }

    func test_fails_when_emailVerification_fails() throws {
        // GIVEN: The user's email adddress verification check fails
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .failure(.unknown(MockError.unknown))

        // WHEN: The router is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        var error: KYCUIKit.RouterError?
        let publisher: AnyPublisher<FlowResult, KYCUIKit.RouterError> = router.presentEmailVerificationIfNeeded(from: mockViewController)
        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let theError) = completion {
                    error = theError
                }
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )
        waitForExpectations(timeout: 1)
        cancellable.cancel()

        // THEN: a meaningful error is returned
        XCTAssertEqual(error, .emailVerificationFailed)
    }

    func test_presents_emailVerificationFlow_when_email_unverfied() throws {
        // GIVEN: The user's email adddress is NOT verified
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .unverified)
        )

        // WHEN: The router is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        let publisher: AnyPublisher<FlowResult, KYCUIKit.RouterError> = router.presentEmailVerificationIfNeeded(from: mockViewController)
        let cancellable = publisher.sink(
            receiveCompletion: { _ in
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )

        // the publisher needs to move to the main queue to present the flow, so we need to wait a bit.
        let delay = expectation(description: "Wait for router to present flow")
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: delay.fulfill)
        wait(for: [delay], timeout: 3)

        // THEN: the email verification flow is presented
        XCTAssertEqual(mockViewController.recordedInvocations.presentViewController.count, 1)
        let presentedViewController = mockViewController.recordedInvocations.presentViewController.first
        let emailVerificationHosting = presentedViewController as? UIHostingController<EmailVerificationView>
        XCTAssertNotNil(emailVerificationHosting)

        // WHEN: The flow completes
        if let store = emailVerificationHosting?.rootView.store {
            let viewStore = ViewStore(store)
            viewStore.send(.emailVerified(.acknowledgeEmailVerification))
        }

        // AND: the controller is dismissed
        XCTAssertEqual(mockViewController.recordedInvocations.dismiss.count, 1)
        mockViewController.recordedInvocations.dismiss.first?.completion?()

        // THEN: The publisher completes
        wait(for: [e], timeout: 1)
        cancellable.cancel()
    }

    func test_doesNotPresent_emailVerificationFlow_when_email_verfied() throws {
        // GIVEN: The user's email adddress is verified
        let e = expectation(description: "Waiting for publisher")
        mockEmailVerificationService.stubbedResults.checkEmailVerificationStatus = .just(
            .init(emailAddress: "test@example.com", status: .verified)
        )

        // WHEN: The router is asked to present the kyc flow if needed
        let mockViewController = MockViewController()
        let publisher: AnyPublisher<FlowResult, KYCUIKit.RouterError> = router.presentEmailVerificationIfNeeded(from: mockViewController)
        let cancellable = publisher.sink(
            receiveCompletion: { _ in
                e.fulfill()
            },
            receiveValue: { _ in
                // no-op
            }
        )
        waitForExpectations(timeout: 1)

        // THEN: the email verification flow is not presented
        XCTAssertEqual(mockViewController.recordedInvocations.presentViewController.count, 0)
        cancellable.cancel()
    }
}
