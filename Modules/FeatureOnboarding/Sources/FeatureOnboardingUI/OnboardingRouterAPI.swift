// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import UIKit

public enum OnboardingResult {
    case abandoned
    case completed
}

public protocol OnboardingRouterAPI {
    func presentOnboarding(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never>
}
