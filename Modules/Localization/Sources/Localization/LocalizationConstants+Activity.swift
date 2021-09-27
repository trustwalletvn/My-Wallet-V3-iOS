// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {
    public enum Activity {
        public enum Message {}
        public enum Details {}
        public enum MainScreen {}
        public enum Pax {}
    }
}

// MARK: MainScreen

extension LocalizationConstants.Activity.MainScreen {
    public static let title = NSLocalizedString(
        "Activity",
        comment: "Activity Screen: title"
    )
    public enum MessageView {
        public static let sharedWithBlockchain = NSLocalizedString("Shared With Blockchain", comment: "Shared With Blockchain")
    }

    public enum Empty {
        public static let title = NSLocalizedString("You Have No Activity", comment: "You Have No Activity")
        public static let subtitle = NSLocalizedString("All your transactions will show up here.", comment: "All your transactions will show up here.")
    }

    public enum Item {
        public static let allWallets = NSLocalizedString("All Wallets", comment: "All Wallets")
        public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")
        public static let trade = NSLocalizedString("Trade", comment: "Trade")
        public static let tradeWallet = trade + " " + wallet
        public static let confirmations = NSLocalizedString("Confirmations", comment: "Confirmations")
        public static let of = NSLocalizedString("of", comment: "of")
        public static let failed = NSLocalizedString("Failed", comment: "Failed")
        public static let send = NSLocalizedString("Send", comment: "Send")
        public static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
        public static let withdraw = NSLocalizedString("Withdraw", comment: "Withdraw")
        public static let buy = NSLocalizedString("Bought", comment: "Bought")
        public static let swap = NSLocalizedString("Swap", comment: "Swap")
        public static let receive = NSLocalizedString("Receive", comment: "Receive")
        public static let sell = NSLocalizedString("Sell", comment: "Sell")
    }
}

// MARK: - MessageView

extension LocalizationConstants.Activity.Message {
    public static let name = NSLocalizedString("My Transaction", comment: "My Transaction")
}

// MARK: Details

extension LocalizationConstants.Activity.Details {

    public static let noDescription = NSLocalizedString("No description", comment: "No description")
    public static let confirmations = NSLocalizedString("Confirmations", comment: "Confirmations")
    public static let of = NSLocalizedString("of", comment: "of")

    public static let completed = NSLocalizedString("Completed", comment: "Completed")
    public static let pending = NSLocalizedString("Pending", comment: "Pending")
    public static let failed = NSLocalizedString("Failed", comment: "Failed")
    public static let refunded = NSLocalizedString("Refunded", comment: "Refunded")
    public static let replaced = NSLocalizedString("Replaced", comment: "Replaced")
    public static let myWallet = NSLocalizedString("My %@ Wallet", comment: "My [Currency Code] Wallet")
    public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")

    public enum Title {
        public static let buy = NSLocalizedString("Bought", comment: "Bought")
        public static let sell = NSLocalizedString("Sell", comment: "Sell")
        public static let gas = NSLocalizedString("Gas", comment: "'Gas' title")
        public static let receive = NSLocalizedString("Receive", comment: "'Receive' title")
        public static let send = NSLocalizedString("Send", comment: "'Send' title")
        public static let swap = NSLocalizedString("Swap", comment: "'Swap' title")
        public static let deposit = NSLocalizedString("Deposit", comment: "Deposit")
        public static let withdraw = NSLocalizedString("Withdraw", comment: "Withdraw")
    }

    public enum Button {
        public static let viewOnExplorer = NSLocalizedString(
            "View on Blockchain Explorer",
            comment: "Button title, button takes user to explorer webpage"
        )
        public static let viewOnStellarChainIO = NSLocalizedString(
            "View on StellarChain.io",
            comment: "Button title, button takes user to StellarChain webpage"
        )
    }
}
