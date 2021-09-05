// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension TransactionalActivityItemEvent.EventStatus: Equatable {
    public static func == (
        lhs: TransactionalActivityItemEvent.EventStatus,
        rhs: TransactionalActivityItemEvent.EventStatus
    ) -> Bool {
        switch (lhs, rhs) {
        case (.pending(confirmations: let left), .pending(confirmations: let right)):
            return left.current == right.current &&
                left.total == right.total
        case (.complete, .complete):
            return true
        default:
            return false
        }
    }
}

extension TransactionalActivityItemEvent.EventType: Equatable {
    public static func == (lhs: TransactionalActivityItemEvent.EventType, rhs: TransactionalActivityItemEvent.EventType) -> Bool {
        switch (lhs, rhs) {
        case (.receive, .receive):
            return true
        case (.send, .send):
            return true
        default:
            return false
        }
    }
}

extension TransactionalActivityItemEvent: Equatable {
    public static func == (lhs: TransactionalActivityItemEvent, rhs: TransactionalActivityItemEvent) -> Bool {
        lhs.status == rhs.status &&
            lhs.type == rhs.type &&
            lhs.identifier == rhs.identifier &&
            lhs.amount == rhs.amount
    }
}
