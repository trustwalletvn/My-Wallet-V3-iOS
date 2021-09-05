// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureAuthenticationDomain
import PlatformKit
import PlatformUIKit
import RxSwift

final class EmailAuthorizationPresenter {

    // MARK: - Types

    private typealias LocalizedString = LocalizationConstants.Onboarding.ManualPairingScreen.EmailAuthorizationAlert

    // MARK: - Services

    private let emailAuthorizationService: EmailAuthorizationServiceAPI
    private let alertPresenter: AlertViewPresenter
    private unowned let routerStateProvider: OnboardingRouterStateProviding

    // MARK: - Setup

    init(
        routerStateProvider: OnboardingRouterStateProviding = resolve(),
        emailAuthorizationService: EmailAuthorizationServiceAPI = resolve(),
        alertPresenter: AlertViewPresenter = .shared
    ) {
        self.emailAuthorizationService = emailAuthorizationService
        self.alertPresenter = alertPresenter
        self.routerStateProvider = routerStateProvider
    }

    // MARK: - API

    /// Starts email authorization. This method is designed to fail silently
    /// As the only option to fail here is `cancellation` by calling `cancel()`
    /// but clients of `EmailAuthorizationPresenter` may subscribe and utilize
    /// `onError(_ error: Error)` if they need to.
    func authorize() -> Completable {
        routerStateProvider.state = .pending2FA
        showAlert()
        return emailAuthorizationService.authorize
            .do(onDispose: { [weak self] in
                self?.routerStateProvider.state = .standard
            })
    }

    /// Cancels polling and waiting for authorization
    func cancel() {
        emailAuthorizationService.cancel()
    }

    // MARK: - Accessors

    private func showAlert() {
        alertPresenter.standardNotify(
            title: LocalizedString.title,
            message: LocalizedString.message,
            actions: [
                UIAlertAction(title: LocalizationConstants.openMailApp, style: .default) { _ in
                    UIApplication.shared.openMailApplication()
                }
            ]
        )
    }
}
