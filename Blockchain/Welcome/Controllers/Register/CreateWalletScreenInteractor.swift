// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import DIKit
import FeatureSettingsDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

// TODO: Refactor this when the coordinators are refactored
/// The interaction layer for wallet creation
final class CreateWalletScreenInteractor: NSObject {

    // MARK: - Exposed Properties

    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())
    var content: Observable<WalletRegistrationContent> {
        contentStateRelay.asObservable()
    }

    /// Any error related to the interaction should be reflected to the presenter
    /// Since the JS is async and callbacks oriented, we
    /// want to use a relay to let the presentation layer
    /// know about errors
    var error: Observable<String> {
        errorRelay.asObservable()
    }

    // MARK: - Injected

    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let wallet: Wallet
    private let walletManager: WalletManager
    private let authenticationCoordinator: AuthenticationCoordinator
    private let errorRelay = PublishRelay<String>()

    // MARK: - Setup

    init(
        reachability: InternetReachabilityAPI = InternetReachability(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        authenticationCoordinator: AuthenticationCoordinator = .shared,
        walletManager: WalletManager = .shared,
        wallet: Wallet = WalletManager.shared.wallet
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager
        self.wallet = wallet
        self.authenticationCoordinator = authenticationCoordinator
        authenticationCoordinator.temporaryAuthHandler = authenticationCoordinator.authenticationHandler
        super.init()
    }
}

// MARK: - RegisterWalletScreenInteracting

extension CreateWalletScreenInteractor: RegisterWalletScreenInteracting {
    func prepare() -> Result<Void, Error> {
        .success(())
    }

    func execute() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachability.ErrorType.internetUnreachable)
        }

        analyticsRecorder.record(event: AnalyticsEvents.Onboarding.walletCreation)

        // Get callback when wallet is done loading
        // Continue in walletJSReady callback
        wallet.delegate = self
        wallet.loadJS()
        return .success(())
    }
}

// MARK: - WalletDelegate (Should be refactored)

extension CreateWalletScreenInteractor: WalletDelegate {
    func walletJSReady() {
        wallet.newAccount(contentStateRelay.value.password, email: contentStateRelay.value.email)
    }

    func didCreateNewAccount(_ guid: String!, sharedKey: String!, password: String!) {
        wallet.delegate = walletManager

        /// Reset wallet + `JSContext`
        walletManager.forgetWallet()

        // Load the newly created wallet
        wallet.load(withGuid: guid, sharedKey: sharedKey, password: password)

        /// Mark the wallet as new
        wallet.isNew = true
        authenticationCoordinator.isCreatingWallet = true

        BlockchainSettings.App.shared.hasEndedFirstSession = false
    }

    func errorCreatingNewAccount(_ message: String!) {
        errorRelay.accept(message ?? "")
    }
}
