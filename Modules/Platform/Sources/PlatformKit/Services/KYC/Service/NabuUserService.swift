// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import RxSwift
import ToolKit

public protocol NabuUserServiceAPI: AnyObject {
    var user: Single<NabuUser> { get }

    func fetchUser() -> Single<NabuUser>
}

final class NabuUserService: NabuUserServiceAPI {

    // MARK: - Exposed Properties

    var user: Single<NabuUser> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            guard case .success = self.semaphore.wait(timeout: .now() + .seconds(30)) else {
                observer(.error(ToolKitError.timedOut))
                return Disposables.create()
            }
            let disposable = self.cachedUser.valueSingle
                .subscribe { event in
                    switch event {
                    case .success(let value):
                        observer(.success(value))
                    case .error(let value):
                        observer(.error(value))
                    }
                }
            return Disposables.create {
                disposable.dispose()
                self.semaphore.signal()
            }
        }
        .subscribeOn(scheduler)
    }

    private let cachedUser = CachedValue<NabuUser>(configuration: .onSubscription())
    private let semaphore = DispatchSemaphore(value: 1)
    private let scheduler = SerialDispatchQueueScheduler(qos: .default)

    private let client: KYCClientAPI
    private let siftService: SiftServiceAPI

    // MARK: - Setup

    init(
        client: KYCClientAPI = resolve(),
        siftService: SiftServiceAPI = resolve()
    ) {
        self.client = client
        self.siftService = siftService

        cachedUser.setFetch(weak: self) { (self) in
            self.client.user()
                .do(
                    onSuccess: { [weak self] nabuUser in
                        self?.siftService.set(userId: nabuUser.identifier)
                    }
                )
        }
    }

    func fetchUser() -> Single<NabuUser> {
        cachedUser.fetchValue
    }
}
