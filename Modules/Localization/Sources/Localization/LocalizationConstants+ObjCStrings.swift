// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

extension LocalizationConstants {
    /// Redefine strings from `Blockchain/LocalizationConstants.h` so they can be captured by any tool used for requesting translations.
    /// This should not be used by non-objc code.
    public enum ObjCStrings {}
}

extension LocalizationConstants.ObjCStrings {
    public static let BC_STRING_ADDRESS = NSLocalizedString("Address", comment: "")
    public static let BC_STRING_ADDRESSES = NSLocalizedString("Addresses", comment: "")
    public static let BC_STRING_ARCHIVE = NSLocalizedString("Archive", comment: "")
    public static let BC_STRING_ARCHIVE_FOOTER_TITLE = NSLocalizedString("Archive this if you do NOT want to use it anymore. Your funds will remain safe, and you can unarchive it at any time.", comment: "")
    public static let BC_STRING_ARCHIVED = NSLocalizedString("Archived", comment: "")
    public static let BC_STRING_ARCHIVED_FOOTER_TITLE = NSLocalizedString("This is archived. Though you cannot send funds from here, any and all funds will remain safe. Simply unarchive to start using it again.", comment: "")
    public static let BC_STRING_ARCHIVING_ADDRESSES = NSLocalizedString("Archiving addresses", comment: "")
    public static let BC_STRING_AT_LEAST_ONE_ADDRESS_REQUIRED = NSLocalizedString("You must have at least one active address", comment: "")
    public static let BC_STRING_CANCEL = NSLocalizedString("Cancel", comment: "")
    public static let BC_STRING_CONTINUE = NSLocalizedString("Continue", comment: "")
    public static let BC_STRING_COPY_ADDRESS = NSLocalizedString("Copy Address", comment: "")
    public static let BC_STRING_COPY_XPUB = NSLocalizedString("Copy xPub", comment: "")
    public static let BC_STRING_CREATE = NSLocalizedString("Create", comment: "")
    public static let BC_STRING_DECRYPTING_PRIVATE_KEY = NSLocalizedString("Decrypting Private Key", comment: "")
    public static let BC_STRING_DEFAULT = NSLocalizedString("Default", comment: "")
    public static let BC_STRING_DONE = NSLocalizedString("Done", comment: "")
    public static let BC_STRING_ERROR = NSLocalizedString("Error", comment: "")
    public static let BC_STRING_ERROR_SAVING_WALLET_CHECK_FOR_OTHER_DEVICES = NSLocalizedString("An error occurred while saving your changes. Please make sure you are not logged into your wallet on another device.", comment: "")
    public static let BC_STRING_EXTENDED_PUBLIC_KEY = NSLocalizedString("Extended Public Key", comment: "")
    public static let BC_STRING_EXTENDED_PUBLIC_KEY_DETAIL_HEADER_TITLE = NSLocalizedString("Your xPub is an advanced feature that contains all of your public addresses.", comment: "")
    public static let BC_STRING_EXTENDED_PUBLIC_KEY_FOOTER_TITLE = NSLocalizedString("Keep your xPub private. Someone with access to your xPub will be able to see all of your funds and transactions.", comment: "")
    public static let BC_STRING_EXTENDED_PUBLIC_KEY_WARNING = NSLocalizedString("Sharing your xPub authorizes others to track your transaction history. As authorized persons may be able to disrupt you from accessing your wallet, only share your xPub with people you trust.", comment: "")
    public static let BC_STRING_IDENTIFIER = NSLocalizedString("Identifier", comment: "")
    public static let BC_STRING_IMPORTED_ADDRESSES = NSLocalizedString("Imported Addresses", comment: "")
    public static let BC_STRING_INVALID_EMAIL_ADDRESS = NSLocalizedString("Invalid email address.", comment: "")
    public static let BC_STRING_INVALID_RECOVERY_PHRASE = NSLocalizedString("Invalid recovery phrase. Please try again", comment: "")
    public static let BC_STRING_LABEL = NSLocalizedString("Label", comment: "")
    public static let BC_STRING_LABEL_ADDRESS = NSLocalizedString("Label Address", comment: "")
    public static let BC_STRING_LABEL_MUST_BE_ALPHANUMERIC = NSLocalizedString("Label must contain letters and numbers only", comment: "")
    public static let BC_STRING_LABEL_MUST_HAVE_LESS_THAN_18_CHAR = NSLocalizedString("Label must have less than 18 characters", comment: "")
    public static let BC_STRING_LEARN_MORE = NSLocalizedString("Learn More", comment: "")
    public static let BC_STRING_LOADING_LOADING_TRANSACTIONS = NSLocalizedString("Loading transactions", comment: "")
    public static let BC_STRING_LOADING_RECOVERING_WALLET = NSLocalizedString("Recovering Funds", comment: "")
    public static let BC_STRING_LOADING_RECOVERING_WALLET_ARGUMENT_FUNDS_ARGUMENT = NSLocalizedString("Found %d, with %@", comment: "")
    public static let BC_STRING_LOADING_RECOVERING_WALLET_CHECKING_ARGUMENT_OF_ARGUMENT = NSLocalizedString("Checking for more: Step %d of %d", comment: "")
    public static let BC_STRING_MAKE_DEFAULT = NSLocalizedString("Make Default", comment: "")
    public static let BC_STRING_NAME = NSLocalizedString("Name", comment: "")
    public static let BC_STRING_NO_LABEL = NSLocalizedString("No Label", comment: "")
    public static let BC_STRING_NOT_NOW = NSLocalizedString("Not now", comment: "")
    public static let BC_STRING_OK = NSLocalizedString("OK", comment: "")
    public static let BC_STRING_SAVE = NSLocalizedString("Save", comment: "")
    public static let BC_STRING_SCAN_PRIVATE_KEY = NSLocalizedString("Scan Private Key", comment: "")
    public static let BC_STRING_SET_DEFAULT_ACCOUNT = NSLocalizedString("Set as Default?", comment: "")
    public static let BC_STRING_SETTINGS_ERROR_LOADING_MESSAGE = NSLocalizedString("Please check your internet connection.", comment: "")
    public static let BC_STRING_SETTINGS_ERROR_LOADING_TITLE = NSLocalizedString("Error loading settings", comment: "")
    public static let BC_STRING_SETTINGS_ERROR_UPDATING_TITLE = NSLocalizedString("Error updating settings", comment: "")
    public static let BC_STRING_TRANSFER_FUNDS = NSLocalizedString("Transfer Funds", comment: "")
    public static let BC_STRING_TRANSFER_FUNDS_DESCRIPTION_ONE = NSLocalizedString("For your safety, we recommend you to transfer any balances in your imported addresses into your Blockchain wallet.", comment: "")
    public static let BC_STRING_TRANSFER_FUNDS_DESCRIPTION_TWO = NSLocalizedString("Your transferred funds will be safe and secure, and you'll benefit from increased privacy and convenient backup and recovery features.", comment: "")
    public static let BC_STRING_UNARCHIVE = NSLocalizedString("Unarchive", comment: "")
    public static let BC_STRING_WALLETS = NSLocalizedString("Wallets", comment: "")
    public static let BC_STRING_WARNING_TITLE = NSLocalizedString("Warning", comment: "")
    public static let BC_STRING_WATCH_ONLY = NSLocalizedString("Watch Only", comment: "")
    public static let BC_STRING_WATCH_ONLY_FOOTER_TITLE = NSLocalizedString("This is a watch-only address. To spend your funds from this wallet, please scan your private key.", comment: "")
    public static let BC_STRING_YOU_MUST_ENTER_A_LABEL = NSLocalizedString("You must enter a label", comment: "")
}
