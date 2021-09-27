// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

extension BuySellActivityItemEvent {
    init(with orderDetails: OrderDetails) {

        let paymentMethod: PaymentMethod
        switch orderDetails.paymentMethod {
        case .bankAccount:
            paymentMethod = .bankAccount
        case .bankTransfer:
            paymentMethod = .bankTransfer
        case .card:
            paymentMethod = .card(paymentMethodId: orderDetails.paymentMethodId)
        case .funds:
            paymentMethod = .funds
        }

        self.init(
            identifier: orderDetails.identifier,
            creationDate: orderDetails.creationDate ?? Date(),
            status: orderDetails.eventStatus,
            inputValue: orderDetails.inputValue,
            outputValue: orderDetails.outputValue,
            fee: orderDetails.fee ?? MoneyValue.zero(currency: orderDetails.inputValue.currencyType),
            isBuy: orderDetails.isBuy,
            paymentMethod: paymentMethod
        )
    }
}

extension OrderDetails {
    fileprivate var eventStatus: BuySellActivityItemEvent.EventStatus {
        switch state {
        case .pendingDeposit,
             .pendingConfirmation,
             .depositMatched:
            return .pending
        case .cancelled:
            return .cancelled
        case .expired:
            return .expired
        case .failed:
            return .failed
        case .finished:
            return .finished
        }
    }
}
