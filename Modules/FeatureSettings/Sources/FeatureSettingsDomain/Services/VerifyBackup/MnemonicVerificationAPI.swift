// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

// TICKET: IOS-2848 - Move Mnemonic Verification Logic from JS to Swift
protocol MnemonicVerificationAPI: AnyObject {
    var isVerified: Single<Bool> { get }

    func verifyMnemonicAndSync() -> Completable
}
