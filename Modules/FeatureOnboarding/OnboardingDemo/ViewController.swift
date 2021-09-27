// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureOnboardingUI
import UIKit

final class ViewController: UIViewController {

    private let featureFlagsService = EphemeralFeatureFlagService()
    private var onboardingRouter: OnboardingRouterAPI?
    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()
        resetRouter()
        featureFlagsService.enable(.showOnboardingAfterSignUp)
        featureFlagsService.enable(.showEmailVerificationInOnboarding)
    }

    @IBAction private func startOnboarding() {
        onboardingRouter?.presentOnboarding(from: self)
            .subscribe(on: DispatchQueue.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] result in
                guard let self = self else {
                    fatalError("💣 ViewController not retained!")
                }
                self.dismiss(animated: true, completion: {
                    let alert = UIAlertController(
                        title: "Onboarding Flow Complete",
                        message: "(\(result))",
                        preferredStyle: .alert
                    )
                    alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                })
            }
            .store(in: &cancellables)
    }

    @IBAction private func resetRouter() {
        onboardingRouter = OnboardingRouter(
            buyCryptoRouter: DemoBuyAdapter(),
            emailVerificationRouter: DemoKYCAdapter(),
            featureFlagsService: featureFlagsService
        )
    }
}
