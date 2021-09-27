// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift

public protocol CustodyActionRouterAPI: AnyObject {
    func next(to state: CustodyActionState)
    func previous()
    func start(with account: BlockchainAccount)

    var completionRelay: PublishRelay<Void> { get }
}
