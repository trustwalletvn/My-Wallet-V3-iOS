// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift
@testable import StellarKit

final class LedgersServiceProviderMock: LedgersServiceProviderAPI {

    var underlyingLedgersService: LedgersServiceAPI!

    var ledgersService: Single<LedgersServiceAPI> {
        .just(underlyingLedgersService)
    }

    init(ledgersService: LedgersServiceAPI) {
        underlyingLedgersService = ledgersService
    }
}
