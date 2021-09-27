// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import EthereumKit
import PlatformKit
import RxSwift

class TransactionFeeClientAPIMock: TransactionFeeClientAPI {
    var underlyingFees: Single<TransactionFeeResponse> = .just(
        .init(
            gasLimit: 10,
            gasLimitContract: 10,
            limits: .init(min: 10, max: 10),
            regular: 10,
            priority: 10
        )
    )

    func fees(cryptoCurrency: CryptoCurrency) -> Single<TransactionFeeResponse> {
        underlyingFees
    }
}
