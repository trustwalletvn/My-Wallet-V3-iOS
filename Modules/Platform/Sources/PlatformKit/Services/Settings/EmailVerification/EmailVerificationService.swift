// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift

public final class EmailVerificationService: EmailVerificationServiceAPI {

    // MARK: - Types

    private enum ServiceError: Error {
        case emailNotVerified
        case pollCancelled
    }

    // MARK: - Properties

    private let syncService: WalletNabuSynchronizerServiceAPI
    private let settingsService: SettingsServiceAPI & EmailSettingsServiceAPI
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)

    // MARK: - Setup

    init(
        syncService: WalletNabuSynchronizerServiceAPI = resolve(),
        settingsService: CompleteSettingsServiceAPI = resolve()
    ) {
        self.syncService = syncService
        self.settingsService = settingsService
    }

    public func cancel() -> Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                self?.isActiveRelay.accept(false)
                observer(.completed)
                return Disposables.create()
            }
    }

    public func verifyEmail() -> Completable {
        start()
            .flatMapCompletable(weak: self) { (self, _) -> Completable in
                self.syncService.sync()
            }
    }

    public func requestVerificationEmail(to email: String, context: FlowContext?) -> Completable {
        settingsService
            .update(email: email, context: context)
            .andThen(syncService.sync())
    }

    /// Start polling by triggering the wallet settings fetch
    private func start() -> Single<Void> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.isActiveRelay.accept(true)
                observer(.success(()))
                return Disposables.create()
            }
            .flatMap(waitForVerification)
    }

    /// Continues the polling only if it has not been cancelled
    private func `continue`() -> Single<Void> {
        isActiveRelay
            .take(1)
            .asSingle()
            .map { isActive in
                guard isActive else {
                    throw ServiceError.pollCancelled
                }
                return ()
            }
            .flatMap(weak: self) { (self, _: ()) -> Single<Void> in
                self.settingsService.fetch(force: true).mapToVoid()
            }
    }

    /// Returns a Single that upon subscription waits until the email is verified.
    /// Only when it streams a value (`Void`) the email is considered `verified`.
    private func waitForVerification() -> Single<Void> {
        self.continue()
            .flatMap(weak: self) { (self, _) -> Single<Void> in
                self.settingsService
                    /// Get the first value and make sure the stream terminates
                    /// by converting it to a `Single`
                    .valueSingle
                    /// Make sure the email is verified, if not throw an error
                    .map(weak: self) { _, settings -> Void in
                        guard settings.isEmailVerified else {
                            throw ServiceError.emailNotVerified
                        }
                        return ()
                    }
                    /// If email is not verified try again
                    .catchError { error -> Single<Void> in
                        switch error {
                        case ServiceError.emailNotVerified:
                            return Single<Int>
                                .timer(
                                    .seconds(1),
                                    scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                                )
                                .flatMap(weak: self) { (self, _) -> Single<Void> in
                                    self.waitForVerification()
                                }
                        default:
                            return self.cancel().andThen(Single.error(ServiceError.pollCancelled))
                        }
                    }
            }
    }
}
