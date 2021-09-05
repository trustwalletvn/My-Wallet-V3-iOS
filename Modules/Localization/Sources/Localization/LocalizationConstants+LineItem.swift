// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// MARK: Groups

extension LocalizationConstants {

    public enum LineItem {
        public enum Transactional {
            public enum Copyable {}
        }
    }
}

// MARK: Transactional

extension LocalizationConstants.LineItem.Transactional {
    public static let bankName = NSLocalizedString(
        "Bank Name",
        comment: "Simple Buy - Bank Name Label"
    )
    public static let iban = NSLocalizedString(
        "IBAN",
        comment: "Simple Buy - IBAN Label"
    )
    public static let bankCountry = NSLocalizedString(
        "Bank Country",
        comment: "Simple Buy - Bank Country Label"
    )
    public static let accountNumber = NSLocalizedString(
        "Account Number",
        comment: "Simple Buy - Account Number Label"
    )
    public static let sortCode = NSLocalizedString(
        "Sort Code",
        comment: "Simple Buy - Sort Code Label"
    )
    public static let routingNumber = NSLocalizedString(
        "Routing Number",
        comment: "Simple Buy - Routing Number Label"
    )
    public static let bankCode = NSLocalizedString(
        "Bank Code (SWIFT/BIC)",
        comment: "Simple Buy - Bank Code Label"
    )
    public static let recipient = NSLocalizedString(
        "Recipient",
        comment: "Simple Buy - Recipient Label"
    )
    public static let amountToSend = NSLocalizedString(
        "Amount to send",
        comment: "Simple Buy - Amount to Send Label"
    )
    public static let date = NSLocalizedString(
        "Date",
        comment: "Date"
    )
    public static let totalCost = NSLocalizedString(
        "Total Cost",
        comment: "Total Cost"
    )
    public static let to = NSLocalizedString(
        "To",
        comment: "To"
    )
    public static let from = NSLocalizedString(
        "From",
        comment: "From"
    )
    public static let gasFor = NSLocalizedString(
        "Gas for",
        comment: "Gas for"
    )
    public static let memo = NSLocalizedString(
        "Description",
        comment: "Description"
    )
    public static let estimatedAmount = NSLocalizedString(
        "Est. Amount",
        comment: "Estimated Amount"
    )
    public static let amount = NSLocalizedString(
        "Amount",
        comment: "Amount"
    )
    public static let value = NSLocalizedString(
        "Value",
        comment: "Value"
    )
    public static let `for` = NSLocalizedString(
        "For",
        comment: "'For', when swaping an asset A for another asset B, this is the title for the amount of B that will be received."
    )
    public static let fee = NSLocalizedString(
        "Fee",
        comment: "Fee"
    )
    public static let buyingFee = NSLocalizedString(
        "Fees",
        comment: "Buying Fee"
    )
    public static let exchangeRate = NSLocalizedString(
        "Exchange Rate",
        comment: "Exchange Rate"
    )
    public static let paymentMethod = NSLocalizedString(
        "Payment Method",
        comment: "Payment Method"
    )
    public static let sendingTo = NSLocalizedString(
        "Sending to",
        comment: "Sending to"
    )
    public static let orderId = NSLocalizedString(
        "Transaction ID",
        comment: "Transaction ID"
    )
    public static let status = NSLocalizedString(
        "Status",
        comment: "Status"
    )
    public static let bankTransfer = NSLocalizedString(
        "Bank Transfer",
        comment: "Bank Transfer"
    )
    public static let availableToTrade = NSLocalizedString(
        "Available to Trade",
        comment: "Available to Trade"
    )
    public static let cryptoPrice = NSLocalizedString(
        "%@ Price",
        comment: "Crypto Price"
    )
    public enum Funds {
        public static let prefix = NSLocalizedString(
            "My",
            comment: "My"
        )
        public static let suffix = NSLocalizedString(
            "Wallet",
            comment: "Wallet"
        )
    }

    public static let creditOrDebitCard = NSLocalizedString(
        "Credit or Debit Card",
        comment: "Simple Buy: Payment method"
    )
    public static let pending = NSLocalizedString(
        "Pending",
        comment: "Pending"
    )
    public static let price = NSLocalizedString("Price", comment: "Price")
    public static let total = NSLocalizedString("Total", comment: "Total")
    public static let wallet = NSLocalizedString("Wallet", comment: "Wallet")
    public static let tradingWallet = NSLocalizedString("Trading Wallet", comment: "Trading Wallet")

    public static let instantly = NSLocalizedString("Instantly", comment: "Simple Buy: Available to Trade description")
}

// MARK: Transactional.Copyable

extension LocalizationConstants.LineItem.Transactional.Copyable {
    public static let bankCode = NSLocalizedString(
        "Bank Code (SWIFT/BIC)",
        comment: "Label for copy item - Bank Code"
    )
    public static let iban = NSLocalizedString(
        "IBAN",
        comment: "Label for copy item - IBAN"
    )
    public static let copied = NSLocalizedString(
        "Copied!",
        comment: "Copied!"
    )
    public static let copyMessageSuffix = NSLocalizedString(
        "is on your clipboard.",
        comment: "Copy label suffix"
    )
    public static let defaultCopyMessage = NSLocalizedString(
        "Detail is on your clipboard.",
        comment: "Copy label suffix"
    )
}
