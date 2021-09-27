// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

extension BitcoinHistoricalTransaction {
    var activityItemEvent: TransactionalActivityItemEvent {
        var status: TransactionalActivityItemEvent.EventStatus
        switch isConfirmed {
        case true:
            status = .complete
        case false:
            status = .pending(
                confirmations: .init(
                    current: confirmations,
                    total: BitcoinHistoricalTransaction.requiredConfirmations
                )
            )
        }
        return .init(
            identifier: identifier,
            transactionHash: transactionHash,
            creationDate: createdAt,
            status: status,
            type: direction == .debit ? .receive : .send,
            amount: amount
        )
    }
}
