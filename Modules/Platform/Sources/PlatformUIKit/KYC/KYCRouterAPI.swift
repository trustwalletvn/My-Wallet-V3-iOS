// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit
import RxSwift

// TICKET: OS-4734 (remove this code)
public enum KYCParentFlow {
    case simpleBuy
    case swap
    case settings
    case announcement
    case resubmission
    case onboarding
    case receive
    case airdrop
    case cash
}

// TICKET: IOS-4734 (remove this code)
public protocol KYCRouterAPI: AnyObject {
    var tier1Finished: Observable<Void> { get }
    var tier2Finished: Observable<Void> { get }

    var kycStopped: Observable<Void> { get }
    var kycFinished: Observable<KYC.Tier> { get }

    func start(parentFlow: KYCParentFlow)
    func start(tier: KYC.Tier, parentFlow: KYCParentFlow)
    func start(tier: KYC.Tier, parentFlow: KYCParentFlow, from viewController: UIViewController?)
}

public enum KYCRouterError: Error {
    case emailVerificationAbandoned
    case emailVerificationFailed
    case kycVerificationAbandoned
    case kycVerificationFailed
    case kycStepFailed
}

public enum KYCRoutingResult: Equatable {
    case abandoned
    case completed
}

public protocol KYCRouting {

    func presentEmailVerificationAndKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError>

    func presentEmailVerificationIfNeeded(
        from presenter: UIViewController
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError>

    func presentKYCIfNeeded(
        from presenter: UIViewController,
        requiredTier: KYC.Tier
    ) -> AnyPublisher<KYCRoutingResult, KYCRouterError>
}
