// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

class DataRepositoryMock: DataRepositoryAPI {
    var underlyingTiers = KYC.UserTiers(tiers: [])

    func fetchTiers() -> Single<KYC.UserTiers> {
        Single.just(underlyingTiers)
    }

    var userSingle: Single<User> {
        user.take(1).asSingle()
    }

    var underlyingUser = UserMock()
    var user: Observable<User> {
        Observable.just(underlyingUser)
    }

    var underlyingNabuUser: NabuUser!

    func fetchNabuUser() -> Single<NabuUser> {
        .just(underlyingNabuUser)
    }

    var nabuUserSingle: Single<NabuUser> {
        .just(underlyingNabuUser)
    }
}
