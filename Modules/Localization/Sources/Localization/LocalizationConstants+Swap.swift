// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {

    public enum Swap {
        public enum Trending {
            public enum Header {
                public static let title = NSLocalizedString(
                    "Swap Your Crypto",
                    comment: "Swap Your Crypto"
                )
                public static let description = NSLocalizedString(
                    "Instantly exchange your crypto into any currency we offer for your wallet.",
                    comment: "Instantly exchange your crypto into any currency we offer for your wallet."
                )
            }

            public static let trending = NSLocalizedString(
                "Trending", comment: "Trending"
            )
            public static let newSwap = NSLocalizedString(
                "New Swap", comment: "New Swap"
            )
        }

        public static let complete = NSLocalizedString(
            "Complete",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let delayed = NSLocalizedString(
            "Delayed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let expired = NSLocalizedString(
            "Expired",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let failed = NSLocalizedString(
            "Failed",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let inProgress = NSLocalizedString(
            "In Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refundInProgress = NSLocalizedString(
            "Refund in Progress",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let refunded = NSLocalizedString(
            "Refunded",
            comment: "Text shown on the exchange list cell indicating the trade status"
        )
        public static let swap = NSLocalizedString(
            "Swap",
            comment: "Text shown for the crypto exchange service."
        )
        public static let receive = NSLocalizedString(
            "Receive",
            comment: "Text displayed when reviewing the amount to be received for an exchange order"
        )
    }
}
