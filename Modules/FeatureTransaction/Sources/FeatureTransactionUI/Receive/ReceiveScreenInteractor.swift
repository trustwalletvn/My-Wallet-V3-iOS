// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import FeatureTransactionDomain
import PlatformKit
import RxRelay
import RxSwift

final class ReceiveScreenInteractor {

    struct State {
        let metadata: CryptoAssetQRMetadata
        let memo: String?
    }

    let account: SingleAccount
    let receiveRouter: ReceiveRouterAPI

    var state: Single<State> {
        account.receiveAddress
            .map { address -> State in
                guard let metadataProvider = address as? CryptoAssetQRMetadataProviding else {
                    throw ReceiveAddressError.notSupported
                }
                return State(metadata: metadataProvider.metadata, memo: address.memo)
            }
    }

    init(account: SingleAccount, receiveRouter: ReceiveRouterAPI = resolve()) {
        self.account = account
        self.receiveRouter = receiveRouter
    }
}
