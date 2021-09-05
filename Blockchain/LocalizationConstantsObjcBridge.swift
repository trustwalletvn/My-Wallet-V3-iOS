// Copyright © Blockchain Luxembourg S.A. All rights reserved.

// swiftlint:disable all

import Foundation

// TODO: deprecate this once Obj-C is no longer using this
/// LocalizationConstants class wrapper so that LocalizationConstants can be accessed from Obj-C.
@objc public class LocalizationConstantsObjcBridge: NSObject {

    @objc public class func requestFailedCheckConnection() -> String { LocalizationConstants.Errors.requestFailedCheckConnection }

    @objc public class func information() -> String { LocalizationConstants.information }

    @objc public class func error() -> String { LocalizationConstants.Errors.error }

    @objc public class func loadingWallet() -> String { LocalizationConstants.Authentication.loadingWallet }

    @objc public class func timedOut() -> String { LocalizationConstants.Errors.timedOut }

    @objc public class func syncingWallet() -> String { LocalizationConstants.syncingWallet }

    @objc public class func nameAlreadyInUse() -> String { LocalizationConstants.Errors.nameAlreadyInUse }

    @objc public class func nonSpendable() -> String { LocalizationConstants.AddressAndKeyImport.nonSpendable }

    @objc public class func balancesErrorGeneric() -> String { LocalizationConstants.Errors.balancesGeneric }

    @objc public class func myBitcoinWallet() -> String { LocalizationConstants.Account.myWallet }

    @objc public class func errorDecryptingWallet() -> String {
        LocalizationConstants.WalletPayloadKit.Error.decryptionFailed
    }
}
