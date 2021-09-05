// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import Localization
import RxSwift
import ToolKit

protocol WalletUpgradeJSServicing: AnyObject {
    /// Upgrades the wallet to V3 and emits "V3"
    /// Fails with `WalletUpgradeError.failedV3Upgrade` if anything went wrong.
    func upgradeToV3() -> Single<String>

    /// Upgrades the wallet to V4 and emits "V4"
    /// Fails with `WalletUpgradeError.failedV4Upgrade` if anything went wrong.
    func upgradeToV4() -> Single<String>
}

enum WalletUpgradeJSError: Error {
    case failedV3Upgrade
    case failedV4Upgrade
}

final class WalletUpgradeJSService: WalletUpgradeJSServicing {

    // MARK: Types

    private enum JSCallback {
        enum V3Payload: NSString {
            case didUpgrade = "objc_upgrade_V3_success"
            case didFail = "objc_upgrade_V3_error"
        }

        enum V4Payload: NSString {
            case didUpgrade = "objc_upgrade_V4_success"
            case didFail = "objc_upgrade_V4_error"
        }
    }

    private enum JSFunction {
        enum V3Payload {
            static func upgrade(with newWalletName: String) -> String {
                "MyWalletPhone.upgradeToV3(\"\(newWalletName)\")"
            }
        }

        enum V4Payload: String {
            case upgrade = "MyWalletPhone.upgradeToV4()"
        }
    }

    // MARK: Private Properties

    private let contextProvider: JSContextProviderAPI

    // MARK: Init

    init(contextProvider: JSContextProviderAPI = resolve()) {
        self.contextProvider = contextProvider
    }

    // MARK: WalletUpgradeJSServicing

    func upgradeToV3() -> Single<String> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            let context = self.contextProvider.jsContext
            let walletName = LocalizationConstants.Account.myWallet
            context.invokeOnce(
                functionBlock: {
                    observer(.success("V3"))
                },
                forJsFunctionName: JSCallback.V3Payload.didUpgrade.rawValue
            )
            context.invokeOnce(
                functionBlock: {
                    observer(.error(WalletUpgradeJSError.failedV3Upgrade))
                },
                forJsFunctionName: JSCallback.V3Payload.didFail.rawValue
            )
            context.evaluateScriptCheckIsOnMainQueue(JSFunction.V3Payload.upgrade(with: walletName))
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.asyncInstance)
    }

    func upgradeToV4() -> Single<String> {
        Single.create(weak: self) { (self, observer) -> Disposable in
            let context = self.contextProvider.jsContext
            context.invokeOnce(
                functionBlock: {
                    observer(.success("V4"))
                },
                forJsFunctionName: JSCallback.V4Payload.didUpgrade.rawValue
            )
            context.invokeOnce(
                functionBlock: {
                    observer(.error(WalletUpgradeJSError.failedV4Upgrade))
                },
                forJsFunctionName: JSCallback.V4Payload.didFail.rawValue
            )
            context.evaluateScriptCheckIsOnMainQueue(JSFunction.V4Payload.upgrade.rawValue)
            return Disposables.create()
        }
        .subscribeOn(MainScheduler.asyncInstance)
    }
}
