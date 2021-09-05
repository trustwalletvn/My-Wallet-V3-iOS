// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxRelay
import RxSwift

public protocol RecoveryPhraseStatusProviding {
    var isRecoveryPhraseVerified: Bool { get }
    var isRecoveryPhraseVerifiedObservable: Observable<Bool> { get }
    var fetchTriggerRelay: PublishRelay<Void> { get }
}
