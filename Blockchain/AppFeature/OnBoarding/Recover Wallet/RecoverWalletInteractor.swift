// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

import AnalyticsKit
import DIKit
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// This is a counterpart of `RecoverWalletScreenInteractor` and it is added so that we be able to
/// use the old screens (soon to be replaced) with the new implementation of the welcome view in FeatureAuthenticationDomain
final class RecoverWalletInteractor: RegisterWalletScreenInteracting {

    // MARK: - Exposed Properties

    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        contentStateRelay.asObservable()
    }

    /// Reflects errors received from the JS layer
    var error: Observable<String> = .empty()

    // MARK: - Injected

    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let wallet: Wallet
    private let walletManager: WalletManager

    /// A passphrase for recovery
    private let passphrase: String

    // MARK: - Accessors

    // MARK: - Setup

    init(
        passphrase: String,
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        reachability: InternetReachabilityAPI = InternetReachability(),
        walletManager: WalletManager = resolve()
    ) {
        self.passphrase = passphrase
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
        wallet = walletManager.wallet
    }

    func prepare() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachability.ErrorType.internetUnreachable)
        }
        wallet.loadJS()
        wallet.recoverFromMetadata(withMnemonicPassphrase: passphrase)
        return .success(())
    }

    func execute() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachability.ErrorType.internetUnreachable)
        }
        wallet.loadJS()

        let email: String = contentStateRelay.value.email
        let password: String = contentStateRelay.value.password
        wallet.recover(
            withEmail: email,
            password: password,
            mnemonicPassphrase: passphrase
        )
        return .success(())
    }
}
