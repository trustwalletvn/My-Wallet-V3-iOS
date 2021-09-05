// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

extension LocalizationConstants {
    public enum CardDetailsScreen {
        public static let title = NSLocalizedString(
            "Add a Card",
            comment: "Add Card Screen: screen title"
        )
        public static let notice = NSLocalizedString(
            "Privacy protected with 256-Bit SSL encryption.",
            comment: "Add Card Screen: privacy notice label"
        )
        public static let button = NSLocalizedString(
            "Next",
            comment: "Add Card Screen: add card button label"
        )
        public enum Alert {
            public static let title = NSLocalizedString(
                "Error",
                comment: "Add Card Screen: Error alert title"
            )
            public static let message = NSLocalizedString(
                "This card has already been saved",
                comment: "Add Card Screen: This card has already been saved"
            )
        }
    }

    public enum BillingAddressScreen {
        public static let title = NSLocalizedString(
            "Billing Address",
            comment: "Billing Address Screen: screen title"
        )
        public static let button = NSLocalizedString(
            "Save My Card",
            comment: "Billing Address Screen: add card button label"
        )
        public static let linkingYourCard = NSLocalizedString(
            "Securely Linking Your Card",
            comment: "Billing Address Screen: loader"
        )
    }

    public enum AuthorizeCardScreen {
        public static let title = NSLocalizedString(
            "Authorize Card",
            comment: "Card Authorization Screen: screen title"
        )
    }

    public enum CountrySelectionScreen {
        public static let title = NSLocalizedString(
            "Select Country",
            comment: "Country Selection Screen: title"
        )
        public static let searchBarPlaceholder = NSLocalizedString(
            "Search Country",
            comment: "Country Selection Screen: search bar placeholder"
        )
    }

    public enum PendingCardStatusScreen {
        public enum LoadingScreen {
            public static let title = NSLocalizedString(
                "Securely Linking Your Card",
                comment: "Pending active card screen: title"
            )
            public static let subtitle = NSLocalizedString(
                "This could take up to 1 minute.",
                comment: "Pending active card screen: subtitle"
            )
        }
    }
}
