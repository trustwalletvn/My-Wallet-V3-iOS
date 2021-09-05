// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import BigInt

public enum CustodialActivityEvent {
    public struct Fiat: Equatable {
        public let amount: FiatValue
        public let identifier: String
        public let date: Date
        public let type: EventType
        public let state: State
    }

    public struct Crypto: Equatable {
        public let amount: CryptoValue
        public let identifier: String
        public let date: Date
        public let type: EventType
        public let state: State
        public let receivingAddress: String
        public let fee: CryptoValue
        public let txHash: String
    }

    public enum EventType: String {
        case deposit = "DEPOSIT"
        case withdrawal = "WITHDRAWAL"
    }

    public enum State: String {
        case completed
        case pending
        case failed
    }
}

extension OrdersActivityResponse.Item {
    var custodialActivityState: CustodialActivityEvent.State? {
        switch state {
        case "COMPLETE":
            return .completed
        case "FAILED":
            return .failed
        case "PENDING", "CLEARED", "FRAUD_REVIEW", "MANUAL_REVIEW":
            return .pending
        default:
            return nil
        }
    }

    var custodialActivityEventType: CustodialActivityEvent.EventType? {
        switch type {
        case "DEPOSIT", "CHARGE":
            return .deposit
        case "WITHDRAWAL":
            return .withdrawal
        default:
            return nil
        }
    }
}

extension CustodialActivityEvent.Fiat {
    init?(item: OrdersActivityResponse.Item) {
        guard let state = item.custodialActivityState else {
            return nil
        }
        guard let eventType = item.custodialActivityEventType else {
            return nil
        }
        guard let fiatCurrency = FiatCurrency(code: item.amount.symbol) else {
            return nil
        }
        let date: Date = DateFormatter.sessionDateFormat.date(from: item.insertedAt)
            ?? DateFormatter.iso8601Format.date(from: item.insertedAt)
            ?? Date()
        self.init(
            amount: FiatValue(amount: BigInt(item.amountMinor) ?? 0, currency: fiatCurrency),
            identifier: item.id,
            date: date,
            type: eventType,
            state: state
        )
    }
}

extension CustodialActivityEvent.Crypto {
    init?(item: OrdersActivityResponse.Item, enabledCurrenciesService: EnabledCurrenciesServiceAPI) {
        guard let state = item.custodialActivityState else {
            return nil
        }
        guard let eventType = item.custodialActivityEventType else {
            return nil
        }
        guard let cryptoCurrency = CryptoCurrency(code: item.amount.symbol, enabledCurrenciesService: enabledCurrenciesService) else {
            return nil
        }
        let date: Date = DateFormatter.sessionDateFormat.date(from: item.insertedAt)
            ?? DateFormatter.iso8601Format.date(from: item.insertedAt)
            ?? Date()
        let amount = CryptoValue(
            amount: BigInt(item.amountMinor) ?? 0,
            currency: cryptoCurrency
        )
        let feeMinor: BigInt = item.feeMinor.flatMap { BigInt($0) } ?? 0
        let fee = CryptoValue(amount: feeMinor, currency: cryptoCurrency)
        self.init(
            amount: amount,
            identifier: item.id,
            date: date,
            type: eventType,
            state: state,
            receivingAddress: item.extraAttributes?.beneficiary?.accountRef ?? "",
            fee: fee,
            txHash: item.txHash ?? ""
        )
    }
}
