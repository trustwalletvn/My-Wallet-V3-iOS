// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// Protocol defining object that have knowledge of the `Wallet`payload version.
public protocol WalletUpgradingAPI: AnyObject {
    /// If the wallet is already initialized.
    var isInitialized: Bool { get }

    /// If the Wallet is already a HD Wallet (V3+).
    var didUpgradeToV3: Bool { get }

    /// If the Wallet is already a HD Wallet (V3+).
    var didUpgradeToV4: Bool { get }

    var requiresV4Upgrade: Single<Bool> { get }
}
