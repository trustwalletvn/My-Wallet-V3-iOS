// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

class WalletNabuSynchronizerServiceAPIMock: WalletNabuSynchronizerServiceAPI {

    func sync() -> Completable {
        .empty()
    }
}
