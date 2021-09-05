// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxRelay
import RxSwift
import ToolKit

/// Service to poll for KYC Tiers updates
public protocol KYCTierUpdatePollingServiceAPI {

    /// Cancel polling
    var cancel: Completable { get }

    /// Start polling until the user reaches a given status on a given tier, or an
    /// given amout of time passes.
    ///
    /// - Parameter desiredTier: The desired tier.
    /// - Parameter desiredStatus: The desired status.
    /// - Parameter seconds: How many seconds long polling should happen.
    func poll(
        untilTier desiredTier: KYC.Tier,
        is desiredStatus: KYC.AccountStatus,
        timeoutAfter seconds: TimeInterval
    ) -> Single<KYC.AccountStatus>
}

/// Service to poll for KYC Tiers updates
final class KYCTierUpdatePollingService: KYCTierUpdatePollingServiceAPI {

    // MARK: - Types

    private enum ServiceError: Error {
        case conditionNotMet
        case pollCancelled
        case timeout(KYC.AccountStatus)
    }

    // MARK: - Properties

    private let tiersService: KYCTiersServiceAPI
    private let isActiveRelay = BehaviorRelay<Bool>(value: false)
    private var endDate: Date = .distantPast

    // MARK: - Setup

    init(tiersService: KYCTiersServiceAPI = resolve()) {
        self.tiersService = tiersService
    }

    /// Cancel polling
    var cancel: Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                self?.isActiveRelay.accept(false)
                observer(.completed)
                return Disposables.create()
            }
    }

    /// Start polling until the user reaches a given status on a given tier, or an
    /// given amout of time passes.
    ///
    /// - Parameter desiredTier: The desired tier.
    /// - Parameter desiredStatus: The desired status.
    /// - Parameter seconds: How many seconds long polling should happen.
    func poll(
        untilTier desiredTier: KYC.Tier,
        is desiredStatus: KYC.AccountStatus,
        timeoutAfter seconds: TimeInterval
    ) -> Single<KYC.AccountStatus> {
        endDate = Date().addingTimeInterval(seconds)
        return start(desiredTier: desiredTier, shouldMatch: desiredStatus)
    }

    /// Start polling by triggering waitForCondition
    private func start(
        desiredTier: KYC.Tier,
        shouldMatch desiredStatus: KYC.AccountStatus
    ) -> Single<KYC.AccountStatus> {
        Single
            .create(weak: self) { (self, observer) -> Disposable in
                self.isActiveRelay.accept(true)
                observer(.success(()))
                return Disposables.create()
            }
            .flatMap(weak: self) { (self, _: ()) -> Single<KYC.AccountStatus> in
                self.waitForCondition(tier: desiredTier, shouldMatch: desiredStatus)
            }
    }

    /// Stop polling if it has been cancelled.
    private var stopPollingIfNecessary: Single<Void> {
        isActiveRelay
            .take(1)
            .asSingle()
            .map { isActive in
                guard isActive else {
                    throw ServiceError.pollCancelled
                }
                return ()
            }
    }

    /// Returns a Single that upon subscription polls until the desired KYC Tier level
    /// is reached or the service timeout.
    private func waitForCondition(
        tier desiredTier: KYC.Tier,
        shouldMatch desiredStatus: KYC.AccountStatus
    ) -> Single<KYC.AccountStatus> {
        stopPollingIfNecessary
            .flatMap(weak: self) { (self, _) -> Single<KYC.AccountStatus> in
                self
                    .tiersService
                    .fetchTiers()
                    .map { $0.tierAccountStatus(for: desiredTier) }
                    .map(weak: self) { (self, status) in
                        try self.checkForTimeout(status: status)
                    }
                    .map(weak: self) { (self, status) in
                        try self.checkForConditionNotMet(status: status, desiredStatus: desiredStatus)
                    }
                    .catchError(weak: self) { (self, error) in
                        self.catchError(error: error, tier: desiredTier, shouldMatch: desiredStatus)
                    }
            }
    }

    private var retryScheduler: Single<Int> {
        Single<Int>
            .timer(
                .seconds(1),
                scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
            )
    }

    /// Catches an error raised by `waitForCondition` and react accordingly.
    private func catchError(error: Error, tier desiredTier: KYC.Tier, shouldMatch desiredStatus: KYC.AccountStatus) -> Single<KYC.AccountStatus> {
        switch error {
        case ServiceError.timeout(let lastKnownStatus):
            return cancel.andThen(Single.just(lastKnownStatus))
        case ServiceError.pollCancelled:
            return cancel.andThen(Single.error(error))
        case ServiceError.conditionNotMet:
            return retryScheduler
                .flatMap(weak: self) { (self, _) -> Single<KYC.AccountStatus> in
                    self.waitForCondition(tier: desiredTier, shouldMatch: desiredStatus)
                }
        default:
            /// Other network errors
            return cancel.andThen(Single.error(error))
        }
    }

    private func checkForTimeout(status: KYC.AccountStatus) throws -> KYC.AccountStatus {
        guard Date().timeIntervalSince(endDate) < 0 else {
            throw ServiceError.timeout(status)
        }
        return status
    }

    private func checkForConditionNotMet(status: KYC.AccountStatus, desiredStatus: KYC.AccountStatus) throws -> KYC.AccountStatus {
        guard status == desiredStatus else {
            throw ServiceError.conditionNotMet
        }
        return status
    }
}
