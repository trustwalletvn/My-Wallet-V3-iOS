// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
import ToolKit

public protocol WalletRecoveryVerifing {
    func isRecoveryPhraseVerified() -> Bool
    func markRecoveryPhraseVerified(completion: (() -> Void)?, error: (() -> Void)?)
}

final class MnemonicVerificationService: MnemonicVerificationAPI {

    enum ServiceError: Error {
        case mnemonicVerificationError
    }

    let walletRecoveryVerifier: WalletRecoveryVerifing
    private let jsScheduler = MainScheduler.instance

    init(walletRecoveryVerifier: WalletRecoveryVerifing) {
        self.walletRecoveryVerifier = walletRecoveryVerifier
    }

    // MARK: - MnemonicVerificationAPI

    var isVerified: Single<Bool> {
        Single
            .just(walletRecoveryVerifier.isRecoveryPhraseVerified())
            .subscribeOn(jsScheduler)
    }

    func verifyMnemonicAndSync() -> Completable {
        Completable
            .create { [weak self] observer -> Disposable in
                guard let self = self else {
                    observer(.error(ToolKitError.nullReference(Self.self)))
                    return Disposables.create()
                }
                self.walletRecoveryVerifier.markRecoveryPhraseVerified(
                    completion: {
                        observer(.completed)
                    },
                    error: {
                        // There was an error syncing wallet.
                        observer(.error(ServiceError.mnemonicVerificationError))
                    }
                )
                return Disposables.create()
            }
            .subscribeOn(jsScheduler)
    }
}
