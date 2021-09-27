// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import ToolKit
import UIKit

final class MockOnboardingEmailVerificationRouter: FeatureOnboardingUI.EmailVerificationRouterAPI {

    struct RecordedInvocations {
        var presentEmailVerification: [UIViewController] = []
    }

    struct StubbedResults {
        var presentEmailVerification: AnyPublisher<OnboardingResult, Never> = .just(.abandoned)
    }

    private(set) var recordedInvocations = RecordedInvocations()
    var stubbedResults = StubbedResults()

    func presentEmailVerification(from presenter: UIViewController) -> AnyPublisher<OnboardingResult, Never> {
        recordedInvocations.presentEmailVerification.append(presenter)
        return stubbedResults.presentEmailVerification
    }
}
