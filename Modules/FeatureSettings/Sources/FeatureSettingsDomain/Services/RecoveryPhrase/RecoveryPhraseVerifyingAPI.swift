// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

public protocol RecoveryPhraseVerifyingServiceAPI {
    var phraseComponents: [String] { get set }
    var selection: [String] { get set }

    func markBackupVerified() -> Completable
}
