// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift
import SettingsKit

final class PasswordRequiredScreenInteractor {

    // MARK: - Properties

    /// Streams potential parsing errors
    var error: Observable<Error> {
        errorRelay.asObservable()
    }

    /// Relay that accepts and streams the payload content
    let passwordRelay = BehaviorRelay<String>(value: "")

    private let walletPayloadService: WalletPayloadServiceAPI
    private let walletFetcher: PairingWalletFetching
    private let appSettings: BlockchainSettings.App
    private let walletManager: WalletManager
    private let credentialsStore: CredentialsStoreAPI

    /// TODO: Consider the various of error types from the service layer,
    /// translate them into a interaction layer errors
    private let errorRelay = PublishRelay<Error>()

    private let disposeBag = DisposeBag()

    // MARK: - Setup

    init(walletPayloadService: WalletPayloadServiceAPI = WalletPayloadService(repository: resolve()),
         walletManager: WalletManager = resolve(),
         walletFetcher: PairingWalletFetching = AuthenticationCoordinator.shared,
         appSettings: BlockchainSettings.App = resolve(),
         credentialsStore: CredentialsStoreAPI = resolve()) {
        self.walletPayloadService = walletPayloadService
        self.walletManager = walletManager
        self.walletFetcher = walletFetcher
        self.appSettings = appSettings
        self.credentialsStore = credentialsStore
    }

    /// Authenticates the wallet
    func authenticate() {
        walletPayloadService.requestUsingSharedKey()
            .subscribe(
                onCompleted: { [weak self] in
                    guard let self = self else { return }
                    self.walletFetcher.authenticate(using: self.passwordRelay.value)
                },
                onError: errorRelay.accept
            )
            .disposed(by: disposeBag)
    }

    /// Forgets the wallet
    func forget() {
        walletManager.forgetWallet()
        appSettings.clear()
        credentialsStore.erase()
    }
}
