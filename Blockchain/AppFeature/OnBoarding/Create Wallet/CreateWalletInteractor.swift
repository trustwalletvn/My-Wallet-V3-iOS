// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import Combine
import CombineExt
import DIKit
import FeatureSettingsDomain
import PlatformKit
import RxRelay
import RxSwift
import ToolKit

/// This is a counterpart of `CreateWalletScreenInteractor` and it is added so that we be able to
/// use the old screens (soon to be replaced) with the new implementation of the welcome view in FeatureAuthenticationDomain
final class CreateWalletInteractor: RegisterWalletScreenInteracting {

    // MARK: - Exposed Properties

    let contentStateRelay = BehaviorRelay(value: WalletRegistrationContent())

    /// Any error related to the interaction should be reflected to the presenter
    /// Since the JS is async and callbacks oriented, we
    /// want to use a relay to let the presentation layer
    /// know about errors
    let error: Observable<String>

    // MARK: - Private

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Injected

    private let reachability: InternetReachabilityAPI
    private let analyticsRecorder: AnalyticsEventRecorderAPI
    private let walletManager: WalletManager

    // MARK: - Setup

    init(
        reachability: InternetReachabilityAPI = InternetReachability(),
        analyticsRecorder: AnalyticsEventRecorderAPI = resolve(),
        walletManager: WalletManager = resolve()
    ) {
        self.analyticsRecorder = analyticsRecorder
        self.reachability = reachability
        self.walletManager = walletManager

        // Handle creation of new account

        let accountCreated = walletManager.didCreateNewAccount
            .share(replay: 1)

        // we're listening to the walletJSReady callback
        // capturing the latest from content, which contains password and email
        // we then request a new account from wallet.
        // The stream is killed once get a successful didCreateNewAccount callback
        walletManager.walletJSisReady
            .withLatestFrom(contentStateRelay.asPublisher()) { $1 }
            .prefix(untilOutputFrom: accountCreated.filter(\.isSuccess))
            .ignoreFailure()
            .sink(receiveValue: { content in
                walletManager.wallet.newAccount(content.password, email: content.email)
            })
            .store(in: &cancellables)

        error = accountCreated
            .filter(\.isFailure)
            .compactMap { value -> String? in
                guard case .failure(let error) = value else {
                    return LocalizationConstants.Errors.genericError
                }
                return error.localizedDescription
            }
            .asObservable()

        // we're listening for a successful `didCreateNewAccount`
        // the code in the observation below is taken from the `CreateWalletScreenInteractor`
        accountCreated
            .filter(\.isSuccess)
            .compactMap(\.successData)
            .sink(receiveValue: { [walletManager] walletCreation in
                /// Reset wallet + `JSContext`
                walletManager.forgetWallet()

                // Load the newly created wallet
                let guid = walletCreation.guid
                let sharedKey = walletCreation.sharedKey
                let password = walletCreation.password
                walletManager.wallet.load(withGuid: guid, sharedKey: sharedKey, password: password)

                /// Mark the wallet as new
                walletManager.wallet.isNew = true

                BlockchainSettings.App.shared.hasEndedFirstSession = false
            })
            .store(in: &cancellables)
    }

    func prepare() -> Result<Void, Error> {
        .success(())
    }

    func execute() -> Result<Void, Error> {
        guard reachability.canConnect else {
            return .failure(InternetReachability.ErrorType.internetUnreachable)
        }

        analyticsRecorder.record(events: [
            AnalyticsEvents.Onboarding.walletCreation,
            AnalyticsEvents.New.Onboarding.walletSignedUp
        ])

        walletManager.wallet.loadJS()
        return .success(())
    }
}
