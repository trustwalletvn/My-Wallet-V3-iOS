// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import RxRelay
import RxSwift

public final class RecoveryPhraseStatusProvider: RecoveryPhraseStatusProviding {

    public let fetchTriggerRelay = PublishRelay<Void>()

    public var isRecoveryPhraseVerifiedObservable: Observable<Bool> {
        fetchTriggerRelay
            .flatMap(weak: self) { (self, _) -> Observable<Bool> in
                .just(self.walletRecoveryVerifier.isRecoveryPhraseVerified())
            }
    }

    public var isRecoveryPhraseVerified: Bool {
        walletRecoveryVerifier.isRecoveryPhraseVerified()
    }

    private let isVerified = PublishRelay<Bool>()
    private let walletRecoveryVerifier: WalletRecoveryVerifing

    public init(walletRecoveryVerifier: WalletRecoveryVerifing = resolve()) {
        self.walletRecoveryVerifier = walletRecoveryVerifier
        isVerified.accept(walletRecoveryVerifier.isRecoveryPhraseVerified())
    }
}
