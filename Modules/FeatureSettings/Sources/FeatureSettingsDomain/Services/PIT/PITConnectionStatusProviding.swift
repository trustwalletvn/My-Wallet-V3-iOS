// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Foundation
import PlatformKit
import RxCocoa
import RxSwift

/// `PITConnectionStatusProviding` is an API for determining if the user
/// has connected their wallet to the PIT
public protocol PITConnectionStatusProviding {
    var hasLinkedPITAccount: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}

public final class PITConnectionStatusProvider: PITConnectionStatusProviding {

    // MARK: - PITConnectionStatusProviding

    public let fetchTriggerRelay = PublishRelay<Void>()

    // MARK: - Private Properties

    private let dataRepository: DataRepositoryAPI

    public init(blockchainRepository: DataRepositoryAPI = resolve()) {
        dataRepository = blockchainRepository
    }

    public var hasLinkedPITAccount: Observable<Bool> {
        Observable.combineLatest(dataRepository.fetchNabuUser().asObservable(), fetchTriggerRelay)
            .flatMap {
                Single.just($0.0.hasLinkedExchangeAccount)
            }
    }
}
