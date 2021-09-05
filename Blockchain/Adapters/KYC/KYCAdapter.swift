// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import KYCKit
import KYCUIKit
import OnboardingUIKit
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

final class KYCAdapter {

    // MARK: - Properties

    private let router: KYCUIKit.Routing

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(router: KYCUIKit.Routing = resolve()) {
        self.router = router
    }

    // MARK: - Public Interface

    func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router
            .presentEmailVerificationAndKYCIfNeeded(
                from: presenter,
                requiredTier: requiredTier
            )
            .eraseToAnyPublisher()
    }

    func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router
            .presentEmailVerificationIfNeeded(from: presenter)
            .eraseToAnyPublisher()
    }

    func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCUIKit.FlowResult, KYCUIKit.RouterError> {
        router
            .presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .eraseToAnyPublisher()
    }
}

// MARK: - PlatformUIKit.KYCRouting

extension KYCRouterError {

    init(_ error: KYCUIKit.RouterError) {
        switch error {
        case .emailVerificationFailed:
            self = .emailVerificationFailed
        case .kycVerificationFailed:
            self = .kycVerificationFailed
        case .kycStepFailed:
            self = .kycStepFailed
        }
    }
}

extension KYCRoutingResult {

    init(_ result: KYCUIKit.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension KYCAdapter: PlatformUIKit.KYCRouting {

    func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationAndKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentEmailVerificationIfNeeded(from: presenter)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }

    func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError> {
        presentKYCIfNeeded(from: presenter, requiredTier: requiredTier)
            .mapError(KYCRouterError.init)
            .map(KYCRoutingResult.init)
            .eraseToAnyPublisher()
    }
}

// MARK: - OnboardingUIKit.EmailVerificationRouterAPI

extension OnboardingResult {

    init(_ result: KYCUIKit.FlowResult) {
        switch result {
        case .abandoned:
            self = .abandoned
        case .completed:
            self = .completed
        }
    }
}

extension KYCAdapter: OnboardingUIKit.EmailVerificationRouterAPI {

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        router.presentEmailVerificationIfNeeded(from: presenter)
            .map(OnboardingResult.init)
            .replaceError(with: OnboardingResult.completed)
            .eraseToAnyPublisher()
    }
}

extension KYCAdapter: PlatformUIKit.TierUpgradeRouterAPI {

    func presentPromptToUpgradeTier(from presenter: UIViewController?, completion: @escaping () -> Void) {
        guard let presenter = presenter ?? UIApplication.shared.topMostViewController else {
            fatalError("A view controller was expected to exist to run \(#function) in \(#file)")
        }
        router.presentPromptToUnlockMoreTrading(from: presenter)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { result in
                // if the result is a successful completion, do nothing
                // we should have called the completion block aready on receive value
                guard case .failure = result else {
                    return
                }
                completion()
            }, receiveValue: { result in
                guard case .completed = result else {
                    // complete only if the KYC upgrade is successful
                    return
                }
                completion()
            })
            .store(in: &cancellables)
    }
}
