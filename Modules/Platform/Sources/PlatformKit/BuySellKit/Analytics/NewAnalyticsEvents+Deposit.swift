// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum Deposit: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case depositClicked(origin: Origin = .currencyPage)
        case depositViewed
        case depositAmountEntered(
            amount: Double,
            currency: String,
            depositMethod: Method
        )
        case depositMethodSelected(
            currency: String,
            depositMethod: Method
        )

        public enum Method: String, StringRawRepresentable {
            case bankTransfer = "BANK_TRANSFER"
            case bankAccount = "BANK_ACCOUNT"
        }

        public enum Origin: String, StringRawRepresentable {
            case currencyPage = "CURRENCY_PAGE"
            case portfolio = "PORTFOLIO"
        }
    }
}
