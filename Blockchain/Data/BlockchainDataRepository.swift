// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import PlatformKit
import RxCocoa
import RxSwift
import ToolKit

// TODO: Refactor and decompose into smaller services
/// Repository for fetching Blockchain data. Accessing properties in this repository
/// will be fetched from the cache (if available), otherwise, data will be fetched over
/// the network and subsequently cached for faster access.
class BlockchainDataRepository: DataRepositoryAPI {

    static let shared = BlockchainDataRepository()

    private let disposeBag = DisposeBag()
    private let userService: NabuUserServiceAPI

    init(userService: NabuUserServiceAPI = resolve()) {
        self.userService = userService
    }

    // MARK: - Public Properties

    var user: Observable<User> {
        userService.user.asObservable().map { $0 }
    }

    var userSingle: Single<User> {
        userService.user.map { $0 }
    }

    var nabuUserSingle: Single<NabuUser> {
        userService.user
    }

    /// Fetches the NabuUser over the network and updates the cached NabuUser if successful
    ///
    /// - Returns: the fetched NabuUser
    func fetchNabuUser() -> Single<NabuUser> {
        userService.fetchUser()
    }
}
