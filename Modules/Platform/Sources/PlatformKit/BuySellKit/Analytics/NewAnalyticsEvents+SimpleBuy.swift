// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum SimpleBuy: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case buySellClicked(
            type: Type,
            origin: Origin
        )
        case buySellViewed(type: Type)
        case buyPaymentMethodSelected(paymentType: PaymentType)
        case buyAmountEntered(
            inputAmount: Double,
            inputCurrency: String,
            maxCardLimit: Double?,
            outputCurrency: String
        )

        public enum PaymentType: String, StringRawRepresentable {
            case bankAccount = "BANK_ACCOUNT"
            case bankTransfer = "BANK_TRANSFER"
            case funds = "FUNDS"
            case paymentCard = "PAYMENT_CARD"

            public init(paymentMethod: PaymentMethod) {
                switch paymentMethod.type {
                case .card:
                    self = .paymentCard
                case .bankAccount:
                    self = .bankAccount
                case .bankTransfer:
                    self = .bankTransfer
                case .funds:
                    self = .funds
                }
            }
        }

        public enum `Type`: String, StringRawRepresentable {
            case buy = "BUY"
            case sell = "SELL"
        }

        public enum Origin: String, StringRawRepresentable {
            case buyWidget = "BUY_WIDGET"
            case dashboardPromo = "DASHBOARD_PROMO"
            case navigation = "NAVIGATION"
            case pendingOrder = "PENDING_ORDER"
            case priceChart = "PRICE_CHART"
            case saving = "SAVINGS"
            case send = "SEND"
            case transationDetails = "TRANSACTION_DETAILS"
            case welcome = "WELCOME"
        }
    }
}
