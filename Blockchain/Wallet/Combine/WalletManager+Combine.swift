// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import PlatformKit

extension WalletManager: WalletManagerReactiveAPI {

    var didCreateNewAccount: AnyPublisher<Result<WalletCreation, WalletCreationError>, Never> {
        rx.didCreateNewAccount
            .asPublisher()
            .ignoreFailure()
    }

    var walletJSisReady: AnyPublisher<Void, Error> {
        rx.walletJSReady
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletAuthDelegate

    /// Reactive wrapper for delegate method `walletDidDecrypt(withSharedKey:guid:)`
    /// - Note: Returns a `WalletDecryption` instance containing info as received from the delegate method
    var didDecryptWallet: AnyPublisher<WalletDecryption, Error> {
        rx.didDecryptWallet
            .asPublisher()
    }

    /// Reactive wrapper for authentication delegate methods
    /// - Note: The following methods will be taken into account and will create a `Result<Bool, AuthenticationError>`:
    /// - `walletDidFinishLoad`
    /// - `walletFailedToLoad`
    /// - `walletFailedToDecrypt`
    var didCompleteAuthentication: AnyPublisher<Result<Bool, AuthenticationError>, Never> {
        rx.didCompleteAuthentication
            .asPublisher()
            .ignoreFailure()
    }

    // MARK: WalletAccountInfoDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfo`
    /// - Note: Invoked when the account info has been retrieved
    var didGetAccountInfo: AnyPublisher<Void, Error> {
        rx.didGetAccountInfo
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletAddressesDelegate

    /// Reactive wrapper for delegate method `returnToAddressesScreen`
    /// - Note: Method invoked when finding a null account or address when checking if archived
    var shouldReturnToAddressesScreen: AnyPublisher<Void, Error> {
        rx.returnToAddressesScreen
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletRecoveryDelegate

    /// Reactive wrapper for delegate method `didRecoverWallet`
    /// - Note:  Method invoked when the recovery sequence is completed
    var walletRecovered: AnyPublisher<Void, Error> {
        rx.didRecoverWallet
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `didFailRecovery`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var walletRecoveryFailed: AnyPublisher<Void, Error> {
        rx.didFailRecovery
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletHistoryDelegate

    /// Reactive wrapper for delegate method `didFailGetHistory`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var walletFailedToGetHistory: AnyPublisher<String?, Error> {
        rx.didFailGetHistory
            .asPublisher()
    }

    // MARK: WalletAccountInfoAndExchangeRatesDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfoAndExchangeRates`
    /// - Note: Method invoked after getting account info and exchange rates on startup
    var walletDidGetAccountInfoAndExchangeRates: AnyPublisher<Void, Error> {
        rx.didGetAccountInfoAndExchangeRates
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletBackupDelegate

    /// Reactive wrapper for delegate method `didBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var walletBackupSuccess: AnyPublisher<Void, Error> {
        rx.didBackupWallet
            .asPublisher()
            .mapToVoid()
    }

    /// Reactive wrapper for delegate method `didFailBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var walletBackupFailed: AnyPublisher<Void, Error> {
        rx.didFailBackupWallet
            .asPublisher()
            .mapToVoid()
    }

    // MARK: WalletSecondPasswordDelegate

    /// Reactive wrapper for delegate method `getSecondPassword`
    /// - Note: Method invoked when second password is required for JS function to complete.
    var getSecondPassword: AnyPublisher<(success: WalletSuccessCallback, dismiss: WalletDismissCallback?), Error> {
        rx.getSecondPassword
            .asPublisher()
    }

    var getPrivateKeyPassword: AnyPublisher<WalletSuccessCallback, Error> {
        rx.getPrivateKeyPassword
            .asPublisher()
    }
}
