// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import ToolKit
import UIKit

public protocol EmailVerificationRouterAPI {
    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}

public protocol BuyCryptoRouterAPI {
    func presentBuyFlow(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}

public class OnboardingRouter: OnboardingRouterAPI {

    // MARK: - Properties

    let buyCryptoRouter: BuyCryptoRouterAPI
    let emailVerificationRouter: EmailVerificationRouterAPI
    let featureFlagsService: FeatureFlagsServiceAPI

    // MARK: - Init

    public init(
        buyCryptoRouter: BuyCryptoRouterAPI = resolve(),
        emailVerificationRouter: EmailVerificationRouterAPI = resolve(),
        featureFlagsService: FeatureFlagsServiceAPI = resolve()
    ) {
        self.buyCryptoRouter = buyCryptoRouter
        self.emailVerificationRouter = emailVerificationRouter
        self.featureFlagsService = featureFlagsService
    }

    // MARK: - Onboarding Routing

    public func presentOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        // Step 1: present email verification
        presentEmailVerification(from: presenter)
            .receive(on: DispatchQueue.main)
            .flatMap { [buyCryptoRouter] result -> AnyPublisher<OnboardingResult, Never> in
                guard case .completed = result else {
                    return .just(.abandoned)
                }
                // Step 2: present the buy flow
                return buyCryptoRouter.presentBuyFlow(from: presenter)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - Helper Methods

    private func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        featureFlagsService.isEnabled(.remote(.showEmailVerificationInOnboarding))
            .flatMap { [emailVerificationRouter] shouldShowEmailVerification -> AnyPublisher<OnboardingResult, Never> in
                guard shouldShowEmailVerification else {
                    return .just(.completed)
                }
                return emailVerificationRouter.presentEmailVerification(from: presenter)
            }
            .eraseToAnyPublisher()
    }
}
