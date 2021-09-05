// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

/// A BlockchainAccount that represents a single account, opposed to a collection of accounts.
public protocol SingleAccount: BlockchainAccount, TransactionTarget {
    var isDefault: Bool { get }
    var sourceState: Single<SourceState> { get }
}

extension SingleAccount {

    public var sourceState: Single<SourceState> {
        .just(.notSupported)
    }
}
