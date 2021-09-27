// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public final class RecoveryPhraseVerifyingService: RecoveryPhraseVerifyingServiceAPI {

    public var phraseComponents: [String] = []
    public var selection: [String] = []

    private let verificationService: MnemonicVerificationService

    public init(wallet: WalletRecoveryVerifing) {
        verificationService = MnemonicVerificationService(walletRecoveryVerifier: wallet)
    }

    public func markBackupVerified() -> Completable {
        verificationService.verifyMnemonicAndSync()
    }
}
