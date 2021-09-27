// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Each `AssetAction` has a different pending screen. This includes
/// the success state as well as the transaction failed state.
protocol PendingTransactionStateProviding: AnyObject {
    func connect(state: Observable<TransactionState>) -> Observable<PendingTransactionPageState>
}
