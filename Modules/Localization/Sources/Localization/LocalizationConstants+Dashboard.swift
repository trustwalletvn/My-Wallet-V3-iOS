// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

extension LocalizationConstants {
    public enum Dashboard {
        public enum AssetDetails {}
        public enum BalanceCell {}
        public enum Portfolio {}
    }
}

extension LocalizationConstants.Dashboard.BalanceCell {
    public enum Title {
        public static let trading = NSLocalizedString("Trading", comment: "Trading")
        public static let savings = NSLocalizedString("Rewards", comment: "Rewards")
    }

    public enum Description {
        public static let savingsPrefix = NSLocalizedString("Earn", comment: "Earn 3% annually")
        public static let savingsSuffix = NSLocalizedString("% annually", comment: "Earn 3% annually")
    }

    public static let pending = NSLocalizedString("Pending", comment: "Pending")
}

extension LocalizationConstants.Dashboard.AssetDetails {
    public static let current = NSLocalizedString("Current", comment: "Current")
    public static let price = NSLocalizedString("Price", comment: "Price")
    public static let send = NSLocalizedString("Send", comment: "Send")
    public static let request = NSLocalizedString("Request", comment: "Request")
    public static let day = NSLocalizedString("Day", comment: "Day")
    public static let week = NSLocalizedString("Week", comment: "Week")
    public static let month = NSLocalizedString("Month", comment: "Month")
    public static let year = NSLocalizedString("Year", comment: "Year")
    public static let all = NSLocalizedString("All", comment: "All")
    public static let sendToWallet = NSLocalizedString("Send to My Wallet", comment: "Send to My Wallet")
    public static let swap = NSLocalizedString("Swap", comment: "Swap")
    public static let viewActivity = NSLocalizedString("View Activity", comment: "View Activity")
}

extension LocalizationConstants.Dashboard.Portfolio {
    public static let totalBalance = NSLocalizedString(
        "Total Balance",
        comment: "Dashboard: total balance component - title"
    )
    public enum EmptyState {
        public static let title = NSLocalizedString(
            "Welcome to Blockchain.com!",
            comment: "Dashboard: Empty State - title"
        )
        public static let subtitle = NSLocalizedString(
            "All your crypto balances will show up here once you buy or receive.",
            comment: "Dashboard: Empty State - subtitle"
        )
        public static let cta = NSLocalizedString(
            "Buy Crypto",
            comment: "Dashboard: Empty State - cta"
        )
    }
}
