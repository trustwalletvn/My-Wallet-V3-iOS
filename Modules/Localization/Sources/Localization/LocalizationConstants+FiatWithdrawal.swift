// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

extension LocalizationConstants {
    public enum FiatWithdrawal {}
}

extension LocalizationConstants.FiatWithdrawal {
    public enum LinkedBanks {
        public enum Navigation {
            public static let title = NSLocalizedString(
                "Linked Banks",
                comment: "Linked Banks"
            )
        }
    }

    public enum EnterAmountScreen {
        public static let title = NSLocalizedString(
            "Withdraw %@",
            comment: "Fiat Withdrawal: `withdraw` from fiat wallet"
        )
        public static let ctaButton = NSLocalizedString(
            "Continue",
            comment: "Fiat Withdrawal: CTA button"
        )
        public static let useMax = NSLocalizedString(
            "Sell Max",
            comment: "Fiat Withdrawal: Amount too high suffix"
        )
        public static let from = NSLocalizedString(
            "From: My %@ Wallet",
            comment: "Fiat Withdrawal: `from` wallet selection"
        )
        public static let to = NSLocalizedString(
            "To: %@ %@",
            comment: "Fiat Withdrawal: `to` bank selection"
        )
        public static let available = NSLocalizedString(
            "Available",
            comment: "Fiat Withdrawal: Available amount"
        )
        public static let withdrawMax = NSLocalizedString(
            "Withdraw Max",
            comment: "Fiat Withdrawal: Withdrawal max amount"
        )
    }

    public enum Checkout {
        public enum Button {
            public static let withdrawTitle = NSLocalizedString(
                "Withdraw %@",
                comment: "Fiat Withdrawal: Order Details - transfer details button"
            )
        }

        public enum Title {
            public static let checkout = NSLocalizedString(
                "Checkout",
                comment: "Checkout screen Title"
            )
            public static let orderDetails = NSLocalizedString(
                "Order Details",
                comment: "Order Details screen Title"
            )
        }

        public enum Summary {
            public static let of = NSLocalizedString(
                "of",
                comment: "Fiat Withdrawal: checkout screen: of (e.g. 100 USD 'of' BTC)"
            )
            public enum Title {
                public static let prefix = NSLocalizedString(
                    "Please review and confirm your ",
                    comment: "Fiat Withdrawal: checkout screen - title prefix"
                )
                public static let suffix = NSLocalizedString(
                    " buy.",
                    comment: "Fiat Withdrawal: checkout screen - title suffix"
                )
            }

            public static let buyButtonPrefix = NSLocalizedString(
                "Buy ",
                comment: "Fiat Withdrawal: checkout screen - buy button prefix"
            )
            public static let sellButtonPrefix = NSLocalizedString(
                "Sell ",
                comment: "Fiat Withdrawal: checkout screen - sell button prefix"
            )
            public static let continueButtonPrefix = NSLocalizedString(
                "OK",
                comment: "Fiat Withdrawal: checkout screen - continue button"
            )
            public static let completePaymentButton = NSLocalizedString(
                "Complete Payment",
                comment: "Fiat Withdrawal: checkout screen - complete payment button"
            )
        }

        public enum Notice {
            public static let funds = NSLocalizedString(
                "Your final amount may change due to market activity.",
                comment: "Fiat Withdrawal: checkout screen notice label for funds"
            )

            public static let cards = NSLocalizedString(
                "Your final amount might change due to market activity. An initial hold period of 3 days will be applied to your funds.",
                comment: "Fiat Withdrawal: checkout screen notice label for cards"
            )

            public enum BankTransfer {
                public static let prefix = NSLocalizedString(
                    "Once we receive your funds, we’ll start your",
                    comment: "Fiat Withdrawal: checkout screen notice label prefix"
                )
                public static let suffix = NSLocalizedString(
                    "buy order. Note, your final amount might change to due market activity. Fees may apply.",
                    comment: "Fiat Withdrawal: checkout screen notice label suffix"
                )
            }
        }

        public enum ConfirmationScreen {
            public enum Loading {
                public static let titlePrefix = NSLocalizedString(
                    "Withdrawing %@",
                    comment: "Fiat Withdrawal: final screen title prefix: Withdraing £500"
                )
                public static let subtitle = NSLocalizedString(
                    "We’re completing your withdrawal now.",
                    comment: "Fiat Withdrawal: final screen subtitle: We’re completing your withdrawal now."
                )
            }

            public enum Success {
                public static let titleSuffix = NSLocalizedString(
                    "%@ Withdrawal",
                    comment: "Fiat Withdrawal: final screen title suffix: E.G £500 Withdrawal"
                )
                public static let subtitle = NSLocalizedString(
                    "Success! We're are withdrawing the cash from your GBP Wallet now. The funds should be in your bank in 1-3 business days.",
                    comment: "Success! We're are withdrawing the cash from your GBP Wallet now. The funds should be in your bank in 1-3 business days."
                )
            }

            public enum Error {
                public static let titleSuffix = NSLocalizedString(
                    "Oops! Something Went Wrong.",
                    comment: "Fiat Withdrawal: error screen"
                )
                public static let subtitle = NSLocalizedString(
                    "Don’t worry. Your money is safe. Please try again or contact our Support Team for help.",
                    comment: "Don’t worry. Your money is safe. Please try again or contact our Support Team for help."
                )
            }

            public static let button = NSLocalizedString(
                "OK",
                comment: "Fiat Withdrawal: final screen ok button"
            )
        }
    }
}

// swiftlint:enable all
