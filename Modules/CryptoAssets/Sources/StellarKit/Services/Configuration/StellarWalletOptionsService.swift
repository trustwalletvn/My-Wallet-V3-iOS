// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxSwift

protocol StellarWalletOptionsBridgeAPI: AnyObject {
    var stellarConfigurationDomain: Single<String?> { get }
}

class StellarWalletOptionsService: StellarWalletOptionsBridgeAPI {
    private let walletOptionsService: WalletOptionsAPI

    init(walletOptions: WalletOptionsAPI = resolve()) {
        walletOptionsService = walletOptions
    }

    var stellarConfigurationDomain: Single<String?> {
        walletOptionsService
            .walletOptions
            .map(\.domains?.stellarHorizon)
    }
}
