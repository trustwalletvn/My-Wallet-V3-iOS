// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct BuySellActivityItemEvent {

    public enum EventStatus {
        case pending
        case cancelled
        case failed
        case expired
        case finished
    }

    public enum PaymentMethod {
        case card(paymentMethodId: String?)
        case bankTransfer
        case bankAccount
        case funds
    }

    public var currencyType: CurrencyType {
        outputValue.currencyType
    }

    public let isBuy: Bool
    public let status: EventStatus
    public let paymentMethod: PaymentMethod

    public let identifier: String

    public let creationDate: Date

    public let inputValue: MoneyValue
    public let outputValue: MoneyValue
    public var fee: MoneyValue

    public init(
        identifier: String,
        creationDate: Date,
        status: EventStatus,
        inputValue: MoneyValue,
        outputValue: MoneyValue,
        fee: MoneyValue,
        isBuy: Bool,
        paymentMethod: PaymentMethod
    ) {
        self.isBuy = isBuy
        self.creationDate = creationDate
        self.identifier = identifier
        self.status = status
        self.inputValue = inputValue
        self.outputValue = outputValue
        self.fee = fee
        self.paymentMethod = paymentMethod
    }
}

extension BuySellActivityItemEvent: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
    }
}

extension BuySellActivityItemEvent: Equatable {
    public static func == (lhs: BuySellActivityItemEvent, rhs: BuySellActivityItemEvent) -> Bool {
        lhs.identifier == rhs.identifier &&
            lhs.status == rhs.status
    }
}
