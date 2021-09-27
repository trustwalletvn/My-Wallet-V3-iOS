// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import PlatformKit
import PlatformUIKit
import RxSwift
import ToolKit

public protocol EmailVerificationInterface: AnyObject {
    func updateLoadingViewVisibility(_ visibility: Visibility)
    func showError(message: String)
    func sendEmailVerificationSuccess()
}

public protocol EmailConfirmationInterface: EmailVerificationInterface {
    func emailVerifiedSuccess()
}

public final class VerifyEmailPresenter {

    public var email: Single<String> {
        emailSettingsService.email
            .observeOn(MainScheduler.instance)
    }

    // MARK: - Private Properties

    private weak var view: EmailVerificationInterface?
    private let emailVerificationService: EmailVerificationServiceAPI
    private let emailSettingsService: EmailSettingsServiceAPI
    private let disposeBag = DisposeBag()

    // MARK: - Setup

    public init(
        view: EmailVerificationInterface,
        emailVerificationService: EmailVerificationServiceAPI = resolve(),
        emailSettingsService: EmailSettingsServiceAPI = resolve()
    ) {
        self.view = view
        self.emailVerificationService = emailVerificationService
        self.emailSettingsService = emailSettingsService
    }

    public func waitForEmailConfirmation() {
        emailVerificationService.verifyEmail()
            .observeOn(MainScheduler.instance)
            .subscribe(
                onCompleted: { [weak view] in
                    guard let view = view as? EmailConfirmationInterface else {
                        return
                    }
                    view.emailVerifiedSuccess()
                }
            )
            .disposed(by: disposeBag)
    }

    public func cancel() {
        emailVerificationService.cancel()
            .subscribe()
            .disposed(by: disposeBag)
    }

    public func sendVerificationEmail(
        to email: String,
        contextParameter: FlowContext? = nil
    ) {
        emailSettingsService.update(email: email, context: contextParameter)
            .observeOn(MainScheduler.instance)
            .do(
                onSubscribed: { [weak view] in
                    view?.updateLoadingViewVisibility(.visible)
                },
                onDispose: { [weak view] in
                    view?.updateLoadingViewVisibility(.hidden)
                }
            )
            .subscribe(
                onCompleted: { [weak view] in
                    view?.sendEmailVerificationSuccess()
                },
                onError: { [weak view] _ in
                    view?.showError(message: LocalizationConstants.KYC.failedToSendVerificationEmail)
                }
            )
            .disposed(by: disposeBag)
    }
}
