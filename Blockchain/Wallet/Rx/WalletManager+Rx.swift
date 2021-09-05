// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import FeatureAuthenticationDomain
import PlatformKit
import RxCocoa
import RxSwift

extension Reactive where Base: WalletManager {

    /// Reactive wrapper for delegate method `didCreateNewAccount(_:sharedKey:password:)`
    /// and `errorCreatingNewAccount(_:)`
    /// Returns a `Result<WalletCreation, WalletCreationError>`
    var didCreateNewAccount: Observable<Result<WalletCreation, WalletCreationError>> {
        let success = base.rx.methodInvoked(#selector(WalletManager.didCreateNewAccount(_:sharedKey:password:)))
            .map { arg -> Result<WalletCreation, WalletCreationError> in
                let guid = try castOrThrow(String.self, arg[0])
                let sharedKey = try castOrThrow(String.self, arg[1])
                let password = try castOrThrow(String.self, arg[2])
                return .success(WalletCreation(guid: guid, sharedKey: sharedKey, password: password))
            }

        let failure = base.rx.methodInvoked(#selector(WalletManager.errorCreatingNewAccount(_:)))
            .map { arg -> Result<WalletCreation, WalletCreationError> in
                let message = try castOrThrow(String?.self, arg[0])
                return .failure(WalletCreationError.message(message))
            }

        return Observable.merge(success, failure)
            .catchError { error -> Observable<Result<WalletCreation, WalletCreationError>> in
                .just(
                    .failure(
                        .unknownError(
                            error.localizedDescription
                        )
                    )
                )
            }
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for delegate method `walletJSReady`
    var walletJSReady: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.walletJSReady))
            .mapToVoid()
            .share(replay: 1, scope: .whileConnected)
    }

    // MARK: WalletAuthDelegate

    /// Reactive wrapper for delegate method `walletDidDecrypt(withSharedKey:guid:)`
    /// - Note: Returns a `WalletDecryption` instance containing info as received from the delegate method
    var didDecryptWallet: Observable<WalletDecryption> {
        base.rx.methodInvoked(#selector(WalletManager.walletDidDecrypt(withSharedKey:guid:)))
            .map { arg in
                let sharedKey = try castOrThrow(String?.self, arg[0])
                let guid = try castOrThrow(String?.self, arg[1])
                let passwordPartHash = base.legacyRepository.legacyPassword?.passwordPartHash
                return WalletDecryption(guid: guid, sharedKey: sharedKey, passwordPartHash: passwordPartHash)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    /// Reactive wrapper for authentication delegate methods
    /// - Note: The following methods will be taken into account and will create a `Result<Bool, AuthenticationError>`:
    /// - `walletDidFinishLoad`
    /// - `walletFailedToLoad`
    /// - `walletFailedToDecrypt`
    var didCompleteAuthentication: Observable<Result<Bool, AuthenticationError>> {
        let success = base.rx.methodInvoked(#selector(WalletManager.walletDidFinishLoad))
            .map { _ in Result<Bool, AuthenticationError>.success(true) }

        let loadError = base.rx.methodInvoked(#selector(WalletManager.walletFailedToLoad))
            .map { _ -> Result<Bool, AuthenticationError> in
                .failure(
                    .init(code: AuthenticationError.ErrorCode.errorDecryptingWallet)
                )
            }

        let decryptError = base.rx.methodInvoked(#selector(WalletManager.walletFailedToDecrypt))
            .map { _ -> Result<Bool, AuthenticationError> in
                .failure(
                    .init(code: AuthenticationError.ErrorCode.failedToLoadWallet)
                )
            }

        return Observable<Result<Bool, AuthenticationError>>
            .merge(success, decryptError, loadError)
            .catchError { error -> Observable<Result<Bool, AuthenticationError>> in
                .just(
                    .failure(
                        AuthenticationError(
                            code: AuthenticationError.ErrorCode.unknown,
                            description: error.localizedDescription
                        )
                    )
                )
            }
            .share(replay: 1, scope: .whileConnected)
    }

    // MARK: WalletAccountInfoDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfo`
    /// - Note: Invoked when the account info has been retrieved
    var didGetAccountInfo: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.walletDidGetAccountInfo))
            .mapToVoid()
            .share()
    }

    // MARK: WalletAddressesDelegate

    /// Reactive wrapper for delegate method `returnToAddressesScreen`
    /// - Note: Method invoked when finding a null account or address when checking if archived
    var returnToAddressesScreen: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.returnToAddressesScreen))
            .mapToVoid()
            .share()
    }

    // MARK: WalletRecoveryDelegate

    /// Reactive wrapper for delegate method `didRecoverWallet`
    /// - Note:  Method invoked when the recovery sequence is completed
    var didRecoverWallet: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.didRecoverWallet))
            .mapToVoid()
            .share()
    }

    /// Reactive wrapper for delegate method `didFailRecovery`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var didFailRecovery: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.didFailRecovery))
            .mapToVoid()
            .share()
    }

    // MARK: WalletHistoryDelegate

    /// Reactive wrapper for delegate method `didFailGetHistory`
    /// - Note:  Method invoked when the recovery sequence fails to complete
    var didFailGetHistory: Observable<String?> {
        base.rx.methodInvoked(#selector(WalletManager.didFailGetHistory(_:)))
            .map { arg in
                let error = try castOrThrow(String?.self, arg[0])
                return error
            }
            .share(replay: 1, scope: .whileConnected)
    }

    // MARK: WalletAccountInfoAndExchangeRatesDelegate

    /// Reactive wrapper for delegate method `walletDidGetAccountInfoAndExchangeRates`
    /// - Note: Method invoked after getting account info and exchange rates on startup
    var didGetAccountInfoAndExchangeRates: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.walletDidGetAccountInfoAndExchangeRates(_:)))
            .mapToVoid()
            .share()
    }

    // MARK: WalletBackupDelegate

    /// Reactive wrapper for delegate method `didBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var didBackupWallet: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.didBackupWallet))
            .mapToVoid()
            .share()
    }

    /// Reactive wrapper for delegate method `didFailBackupWallet`
    /// - Note: Method invoked when backup sequence is completed
    var didFailBackupWallet: Observable<Void> {
        base.rx.methodInvoked(#selector(WalletManager.didFailBackupWallet))
            .mapToVoid()
            .share()
    }

    // MARK: WalletSecondPasswordDelegate

    /// Reactive wrapper for delegate method `getSecondPassword`
    /// - Note: Method invoked when second password is required for JS function to complete.
    var getSecondPassword: Observable<(success: WalletSuccessCallback, dismiss: WalletDismissCallback?)> {
        base.rx.methodInvoked(#selector(WalletManager.getSecondPassword(withSuccess:dismiss:)))
            .map { arg in
                let success = try castOrThrow(WalletSuccessCallback.self, arg[0])
                let dismiss = try castOrThrow(WalletDismissCallback?.self, arg[1])
                return (success, dismiss)
            }
            .share(replay: 1, scope: .whileConnected)
    }

    var getPrivateKeyPassword: Observable<WalletSuccessCallback> {
        base.rx.methodInvoked(#selector(WalletManager.getSecondPassword(withSuccess:dismiss:)))
            .map { arg in
                let success = try castOrThrow(WalletSuccessCallback.self, arg[0])
                return success
            }
            .share(replay: 1, scope: .whileConnected)
    }
}

private func castOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let returnValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }

    return returnValue
}
