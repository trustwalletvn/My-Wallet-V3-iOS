// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension Accessibility.Identifier {

    enum SimpleBuy {

        enum IntroScreen {
            private static let prefix = "Intro."
            static let themeBackgroundImageView = "\(prefix)themeBackgroundImageView"
        }

        enum KYCInvalidScreen {
            private static let prefix = "KYCInvalidScreen."
            static let contactSupportButton = "\(prefix)contactSupportButton"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
        }

        enum IneligibleScreen {
            private static let prefix = "IneligibleScreen."
            static let title = "\(prefix)title"
            static let subtitle = "\(prefix)subtitle"
            static let learnMoreButton = "\(prefix)learnMoreButton"
        }

        enum BuyScreen {
            private static let prefix = "Buy."
            static let minimumBuy = "\(prefix)MinimumBuy"
            static let maximumBuy = "\(prefix)MaximumBuy"
            static let paymentMethodTitle = "\(prefix)paymentMethodTitle"
            static let selectPaymentMethodLabel = "\(prefix)selectPaymentMethodLabel"
        }

        enum SellScreen {
            private static let prefix = "Sell."
        }

        enum PaymentMethodsScreen {
            private static let prefix = "PaymentMethods."
            static let addCard = "\(prefix)AddCard"
            static let addBank = "\(prefix)AddBank"
            static let depositCash = "\(prefix)DepositCash"
            static let linkedBank = "\(prefix)LinkedBank"
        }

        enum Checkout {
            private static let prefix = "Checkout."
            static let lineItemPrefix = prefix
            static let cryptoAmountPrefix = prefix + Accessibility.Identifier.LineItem.Transactional.cryptoAmount
            static let fiatAmountPrefix = prefix + Accessibility.Identifier.LineItem.Transactional.fiatAmount
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
            static let disclaimerImage = "\(prefix)disclaimerImage"

            public enum Button {
                static let transferDetails = "\(prefix)transferDetails"
            }
        }

        enum TransferDetails {
            private static let prefix = "TransferDetails."
            static let lineItemPrefix = prefix
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let disclaimerLabel = "\(prefix)disclaimerLabel"
            static let disclaimerImage = "\(prefix)disclaimerImage"
        }

        enum Cancellation {
            private static let prefix = "Cancellation."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let yesButton = "\(prefix)yesButton"
            static let noButton = "\(prefix)noButton"
        }

        enum IneligibleCurrency {
            private static let prefix = "IneligibleCurrency."
            static let titleLabel = "\(prefix)titleLabel"
            static let descriptionLabel = "\(prefix)descriptionLabel"
            static let changeCurrency = "\(prefix)changeCurrency"
            static let viewHome = "\(prefix)viewHome"
        }
    }
}

extension Accessibility.Identifier.SimpleBuy {
    enum KYCScreen {
        static let titleLabel = "titleLabel"
        static let subtitleLabel = "subtitleLabel"
        static let goToWalletButton = "goToWalletButton"
    }
}
