// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Foundation

extension AnalyticsEvents.New {
    public enum Sell: AnalyticsEvent {

        public var type: AnalyticsEventType { .nabu }

        case sellAmountEntered(
            fromAccountType: FromAccountType,
            inputAmount: Double,
            inputCurrency: String,
            outputCurrency: String
        )
        case sellAmountMaxClicked(
            fromAccountType: FromAccountType,
            inputCurrency: String,
            outputCurrency: String
        )
        case sellAmountMinClicked(
            fromAccountType: FromAccountType,
            inputCurrency: String,
            outputCurrency: String
        )
        case sellFromSelected(
            fromAccountType: FromAccountType,
            inputCurrency: String
        )

        public enum FromAccountType: String, StringRawRepresentable {
            case savings = "SAVINGS"
            case trading = "TRADING"
            case userKey = "USERKEY"

            public init(_ account: CryptoAccount) {
                switch account {
                case is CryptoInterestAccount:
                    self = .savings
                case is CryptoTradingAccount:
                    self = .trading
                default:
                    self = .userKey
                }
            }
        }
    }
}
