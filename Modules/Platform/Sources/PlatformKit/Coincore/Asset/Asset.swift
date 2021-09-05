// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

public protocol Asset: AnyObject {

    /// Gives a chance for the `Asset` to initialize itself.
    func initialize() -> Completable

    func accountGroup(filter: AssetFilter) -> Single<AccountGroup>

    func transactionTargets(account: SingleAccount) -> Single<[SingleAccount]>

    /// Validates the given address
    /// - Parameter address: A `String` value of the address to be parse
    func parse(address: String) -> Single<ReceiveAddress?>
}
