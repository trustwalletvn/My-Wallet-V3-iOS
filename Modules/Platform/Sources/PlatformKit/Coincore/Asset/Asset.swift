// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import Localization
import RxSwift
import ToolKit

public enum AssetError: LocalizedError {
    case assetInitialisationFailed(Error)
}

public protocol Asset: AnyObject {

    /// Gives a chance for the `Asset` to initialize itself.
    func initialize() -> AnyPublisher<Void, AssetError>

    func accountGroup(filter: AssetFilter) -> AnyPublisher<AccountGroup, Never>

    func transactionTargets(account: SingleAccount) -> AnyPublisher<[SingleAccount], Never>

    /// Validates the given address
    /// - Parameter address: A `String` value of the address to be parse
    func parse(address: String) -> AnyPublisher<ReceiveAddress?, Never>
}
