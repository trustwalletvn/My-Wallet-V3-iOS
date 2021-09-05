// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import Foundation
import RxCombine
import RxRelay
import RxSwift
import ToolKit

public final class EmailAuthorizationService: EmailAuthorizationServiceAPI {

    /// Steams a `completed` event once, upon successful authorization.
    /// Keeps polling until completion event is received
    public var authorize: Completable {
        authorizeEmail()
            .asCompletable()
    }

    private let lock = NSRecursiveLock()
    private var _isActive = false
    private var isActive: Bool {
        get {
            lock.lock()
            defer { lock.unlock() }
            return _isActive
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            _isActive = newValue
        }
    }

    // MARK: - Injected

    private let guidService: GuidServiceAPI

    // MARK: - Setup

    public init(guidService: GuidServiceAPI) {
        self.guidService = guidService
    }

    /// Cancels the authorization by sending interrupt to stop polling
    public func cancel() {
        isActive = false
    }

    // MARK: - Accessors

    public func authorizeEmailPublisher() -> AnyPublisher<Void, EmailAuthorizationServiceError> {
        guidService
            .guid
            .mapToVoid()
            .catch { error -> AnyPublisher<Void, EmailAuthorizationServiceError> in
                switch error {
                case .missingGuid:
                    return .failure(.missingGuid)
                case .missingSessionToken:
                    return .failure(.missingSessionToken)
                case .networkError(let networkError):
                    return .failure(.guidService(.networkError(networkError)))
                }
            }
            .eraseToAnyPublisher()
    }

    private func authorizeEmail() -> Single<Void> {
        guard !isActive else {
            return .error(EmailAuthorizationServiceError.authorizationAlreadyActive)
        }
        isActive = true
        return guidService
            .guid // Fetch the guid
            .asObservable()
            .asSingle()
            .mapToVoid() // Map to void as we just want to verify it could be retrieved
            /// Any error should be caught and unless the request was cancelled or
            /// session token was missing, just keep polling until the guid is retrieved
            .catchError { [weak self] error -> Single<Void> in
                guard let self = self else { throw EmailAuthorizationServiceError.unretainedSelf }
                /// In case the session token is missing, don't continue since the `sessionToken`
                /// is essential to form the request
                switch error {
                case GuidServiceError.missingSessionToken:
                    self.cancel()
                    throw EmailAuthorizationServiceError.missingSessionToken
                default:
                    break
                }
                guard self.isActive else {
                    throw EmailAuthorizationServiceError.authorizationCancelled
                }
                return Single<Int>
                    .timer(
                        .seconds(2),
                        scheduler: ConcurrentDispatchQueueScheduler(qos: .background)
                    )
                    .flatMap(weak: self) { (self, _) -> Single<Void> in
                        self.isActive = false
                        return self.authorizeEmail()
                    }
            }
    }
}
