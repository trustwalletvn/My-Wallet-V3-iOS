// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol CryptoNonCustodialAccount: CryptoAccount, NonCustodialAccount {
    func updateLabel(_ newLabel: String) -> Completable
    /// Creates and return a On Chain `TransactionEngine` for this account `CryptoCurrency`.
    func createTransactionEngine() -> Any
}

extension CryptoNonCustodialAccount {
    public var requireSecondPassword: Single<Bool> {
        .just(false)
    }

    public var isFunded: Single<Bool> {
        balance
            .map(\.isPositive)
    }

    public func updateLabel(_ newLabel: String) -> Completable {
        .error(PlatformKitError.illegalStateException(message: "Cannot update account label for \(asset.name) accounts"))
    }

    /// The `OrderDirection` for which an `CryptoNonCustodialAccount` could have custodial events.
    public var custodialDirections: Set<OrderDirection> {
        [.fromUserKey, .onChain]
    }

    /// Treats an `[TransactionalActivityItemEvent]`, replacing any event matching one of the `SwapActivityItemEvent` with the said match.
    public static func reconcile(
        swapEvents: [SwapActivityItemEvent],
        noncustodial: [TransactionalActivityItemEvent]
    ) -> [ActivityItemEvent] {
        noncustodial.map { event -> ActivityItemEvent in
            guard event.type == .send else {
                return .transactional(event)
            }
            guard let swap = swapEvents.first(where: { swapEvent in
                guard let transactionID = swapEvent.kind.depositTxHash else {
                    return false
                }
                return transactionID.caseInsensitiveCompare(event.identifier) == .orderedSame
            }) else {
                return .transactional(event)
            }
            return .swap(swap)
        }
    }
}
