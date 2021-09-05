// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents {
    public enum FiatWithdrawal: AnalyticsEvent {
        case formShown
        case confirm(currencyCode: String, amount: String)
        case checkout(CheckoutFormEvent)
        case withdrawSuccess(currencyCode: String)
        case withdrawFailure(currencyCode: String)

        public enum CheckoutFormEvent {
            case shown(currencyCode: String)
            case confirm(currencyCode: String)
            case cancel(currencyCode: String)

            var name: String {
                switch self {
                case .shown:
                    return "cash_withdraw_checkout_shown"
                case .confirm:
                    return "cash_withdraw_checkout_confirm"
                case .cancel:
                    return "cash_withdraw_checkout_cancel"
                }
            }
        }

        public var name: String {
            switch self {
            case .formShown:
                return "cash_withdraw_form_shown"
            case .confirm:
                return "cash_witdraw_form_confirm_click"
            case .checkout(let value):
                return value.name
            case .withdrawSuccess:
                return "cash_withdraw_success"
            case .withdrawFailure:
                return "cash_withdraw_error"
            }
        }

        public var params: [String: String]? {
            switch self {
            case .formShown:
                return nil
            case .confirm(let currencyCode, let amount):
                return ["currency": currencyCode, "amount": amount]
            case .checkout(let value):
                switch value {
                case .shown(let currencyCode),
                     .cancel(let currencyCode),
                     .confirm(let currencyCode):
                    return ["currency": currencyCode]
                }
            case .withdrawFailure(let currencyCode),
                 .withdrawSuccess(let currencyCode):
                return ["currency": currencyCode]
            }
        }
    }
}
