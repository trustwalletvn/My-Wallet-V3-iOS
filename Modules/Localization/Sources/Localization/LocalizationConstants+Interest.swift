// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum Interest {
        public enum Screen {
            public enum IdentityVerification {}
            public enum Announcement {}
            public enum AccountDetails {}
        }
    }
}

// MARK: - Screen.Announcement

extension LocalizationConstants.Interest.Screen.Announcement {
    public static let title = NSLocalizedString("Earn Interest on Your Crypto", comment: "Earn Interest on Your Crypto")
    public static let description = NSLocalizedString("Start earning. Add BTC to your Interest Account.", comment: "Start earning. Add BTC to your Interest Account.")
    public enum Cells {
        public enum LineItem {
            public enum Rate {
                public static let title = NSLocalizedString("Current Rate", comment: "Current Rate")
            }

            public enum Interest {
                public static let title = NSLocalizedString("Interest Paid", comment: "Interest Paid")
                public static let description = NSLocalizedString("1st of Every Month", comment: "1st of Every Month")
            }

            public enum Currencies {
                public static let title = NSLocalizedString("Available Currencies", comment: "Available Currencies")
            }
        }

        public enum Footer {
            public static let title = NSLocalizedString("Please manage your BTC Interest Account on the web at blockchain.com", comment: "Please manage your BTC Interest Account on the web at blockchain.com")
        }

        public enum Button {
            public static let title = NSLocalizedString("Visit Blockchain.com", comment: "Visit Blockchain.com")
        }
    }
}

// MARK: - Screen.IdentityVerification

extension LocalizationConstants.Interest.Screen.IdentityVerification {
    public static let title = NSLocalizedString("Earn Interest on Your Crypto", comment: "Earn Interest on Your Crypto")
    public static let description = NSLocalizedString("Verify your identity and earn up to 9.0% annually.", comment: "Verify your identity and earn up to 9.0% annually.")
    public static let action = NSLocalizedString("Verify My Identity", comment: "Verify My Identity")
    public static let notNow = NSLocalizedString("Not Now", comment: "Not Now")
    public enum List {
        public enum First {
            public static let title = NSLocalizedString("Verify Your Identity", comment: "Verify Your Identity")
            public static let description = NSLocalizedString(
                "To prevent identity theft or fraud, we'll need to make sure it's really you by uploading an ID.",
                comment: "To prevent identity theft or fraud, we'll need to make sure it's really you by uploading an ID."
            )
        }

        public enum Second {
            public static let title = NSLocalizedString("Add BTC to Your Interest Account", comment: "Add BTC to Your Interest Account")
            public static let description = NSLocalizedString(
                "Send Bitcoin to your new Interest Account. Deposit and withdraw at any time.",
                comment: "Send Bitcoin to your new Interest Account. Deposit and withdraw at any time."
            )
        }

        public enum Third {
            public static let title = NSLocalizedString("Get Paid", comment: "Get Paid")
            public static let description = NSLocalizedString(
                "See your crypto balance increase every day. Get paid on the 1st of every month.",
                comment: "See your crypto balance increase every day. Get paid on the 1st of every month."
            )
        }
    }
}

// MARK: - Screen.AccountDetails

extension LocalizationConstants.Interest.Screen.AccountDetails {
    public static let annually = NSLocalizedString("Annually", comment: "Annually")
    public enum Cell {
        public enum Balance {
            public static let title = NSLocalizedString("Interest Account", comment: "Interest Account")
        }

        public enum Default {
            public enum Total {
                public static let title = NSLocalizedString("Total Interest Earned", comment: "Total Interest Earned")
            }

            public enum Next {
                public static let title = NSLocalizedString("Next Interest Payment", comment: "Next Interest Payment")
            }

            public enum Accrued {
                public static let title = NSLocalizedString(
                    "Accrued Interest This Month",
                    comment: "Accrued Interest This Month"
                )
            }

            public enum Hold {
                public static let title = NSLocalizedString(
                    "Initial Hold Period",
                    comment: "Initial Hold Period"
                )
            }

            public enum Rate {
                public static let title = NSLocalizedString(
                    "Interest Rate",
                    comment: "Interest Rate"
                )
            }
        }

        public enum Footer {
            public static let title = NSLocalizedString(
                "Manage your %@ Interest Account on the web at blockchain.com",
                comment: "Manage your %@ Interest Account on the web at blockchain.com"
            )
        }
    }
}
