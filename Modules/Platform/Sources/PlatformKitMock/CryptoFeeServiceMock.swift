// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

final class CryptoFeeServiceMock<FeeType: TransactionFee & Decodable>: CryptoFeeServiceAPI {

    var underlyingFees: FeeType!

    var fees: Single<FeeType> {
        .just(underlyingFees)
    }

    init(underlyingFees: FeeType? = FeeType.default) {
        self.underlyingFees = underlyingFees
    }
}
