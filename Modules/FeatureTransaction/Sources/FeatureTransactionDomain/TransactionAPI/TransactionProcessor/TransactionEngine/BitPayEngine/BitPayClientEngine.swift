// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol EngineTransaction {
    var encodedMsg: String { get }
    var msgSize: Int { get }
    var txHash: String { get }
}

public struct BitPayEngineTransaction: EngineTransaction {
    public let encodedMsg: String
    public let msgSize: Int
    public let txHash: String

    public init(msgSize: Int, txHash: String, encodedMsg: String = "") {
        self.msgSize = msgSize
        self.txHash = txHash
        self.encodedMsg = encodedMsg
    }
}

public protocol BitPayClientEngine {
    func doPrepareTransaction(pendingTransaction: PendingTransaction, secondPassword: String) -> Single<EngineTransaction>
    func doOnTransactionSuccess(pendingTransaction: PendingTransaction)
    func doOnTransactionFailed(pendingTransaction: PendingTransaction, error: Error)
}
