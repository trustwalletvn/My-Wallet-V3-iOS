// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import StellarKit

extension StellarLedger {
    static var mock: StellarLedger {
        StellarLedger(
            identifier: "",
            token: "",
            sequence: 0,
            transactionCount: nil,
            operationCount: 0,
            closedAt: Date(),
            totalCoins: "",
            baseFeeInStroops: nil,
            baseReserveInStroops: nil
        )
    }
}
