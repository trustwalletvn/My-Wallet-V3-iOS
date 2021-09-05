// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum Withdrawal: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case linkBankClicked(origin: LinkBank.Origin)
        case linkBankConditionsApproved(
            bankName: String,
            partner: LinkBank.Partner,
            provider: LinkBank.Provider
        )
        case linkBankSelected(
            bankName: String,
            partner: LinkBank.Partner
        )
        case withdrawalAmountEntered(
            currency: String,
            inputAmount: Double,
            outputAmount: Double,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalAmountMaxClicked(
            amountCurrency: String?,
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalAmountMinClicked(
            amountCurrency: String?,
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalClicked(origin: Withdrawal.Origin)
        case withdrawalMethodSelected(
            currency: String,
            withdrawalMethod: Withdrawal.Method
        )
        case withdrawalViewed

        public enum LinkBank {
            public enum Origin: String, StringRawRepresentable {
                case buy = "BUY"
                case deposit = "DEPOSIT"
                case settings = "SETTINGS"
                case withdraw = "WITHDRAW"
            }

            public enum Partner: String, StringRawRepresentable {
                case yapidly = "YAPILY"
                case yodlee = "YODLEE"
            }

            public enum Provider: String, StringRawRepresentable {
                case fintecture = "FINTECTURE"
                case safeConnect = "SAFE_CONNECT"
            }
        }

        public enum Withdrawal {
            public enum Method: String, StringRawRepresentable {
                case bankAccount = "BANK_ACCOUNT"
                case bankTransfer = "BANK_TRANSFER"
            }

            public enum Origin: String, StringRawRepresentable {
                case currencyPage = "CURRENCY_PAGE"
                case portfolio = "PORTFOLIO"
            }
        }
    }
}
