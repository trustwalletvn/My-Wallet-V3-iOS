// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureKYCDomain
import FeatureKYCUI
import FeatureOnboardingUI
import SwiftUI
import UIKit

final class DemoKYCAdapter: FeatureOnboardingUI.EmailVerificationRouterAPI {

    let router: FeatureKYCUI.Routing = {
        let mockEmailVerificationService = MockEmailVerificationService()
        return FeatureKYCUI.Router(
            emailVerificationService: mockEmailVerificationService,
            openMailApp: { completion in
                mockEmailVerificationService.stubbedVerificationStatus = .verified
                completion(true)
            }
        )
    }()

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map { result in
                guard case .completed = result else {
                    return .abandoned
                }
                return .completed
            }
            .replaceError(with: OnboardingResult.abandoned)
            .eraseToAnyPublisher()
    }
}

private final class MockEmailVerificationService: FeatureKYCDomain.EmailVerificationServiceAPI {

    fileprivate var stubbedVerificationStatus: EmailVerificationResponse.Status = .unverified

    func checkEmailVerificationStatus() -> AnyPublisher<EmailVerificationResponse, EmailVerificationCheckError> {
        Just(EmailVerificationResponse(emailAddress: "test@example.com", status: stubbedVerificationStatus))
            .setFailureType(to: EmailVerificationCheckError.self)
            .eraseToAnyPublisher()
    }

    func sendVerificationEmail(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Fail(error: UpdateEmailAddressError.missingCredentials)
            .eraseToAnyPublisher()
    }

    func updateEmailAddress(to emailAddress: String) -> AnyPublisher<Void, UpdateEmailAddressError> {
        Fail(error: UpdateEmailAddressError.missingCredentials)
            .eraseToAnyPublisher()
    }
}
