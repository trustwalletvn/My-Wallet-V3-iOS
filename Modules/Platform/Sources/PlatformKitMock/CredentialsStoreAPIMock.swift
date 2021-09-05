// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

class CredentialsStoreAPIMock: CredentialsStoreAPI {

    func backup(pinDecryptionKey: String) -> Completable {
        .empty()
    }

    var expectedPinDataCalled: Bool = false
    var expectedPinData: CredentialsPinData?

    func pinData() -> CredentialsPinData? {
        expectedPinDataCalled = true
        return expectedPinData
    }

    var expectedWalletData: Single<CredentialsWalletData> = .error(NSError(domain: "Error", code: 1, userInfo: nil))

    func walletData(pinDecryptionKey: String) -> Single<CredentialsWalletData> {
        expectedWalletData
    }

    var synchronizeCalled = false

    func synchronize() {
        synchronizeCalled = true
    }

    var eraseCalled = false

    func erase() {
        eraseCalled = true
    }
}
