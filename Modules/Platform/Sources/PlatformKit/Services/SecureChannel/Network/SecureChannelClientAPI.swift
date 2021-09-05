// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol SecureChannelClientAPI: AnyObject {
    func sendMessage(msg: SecureChannel.PairingResponse) -> Completable
    func getIp() -> Single<String>
}
