// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
@testable import StellarKit
import stellarsdk
import XCTest

final class LedgersServiceMock: LedgersServiceAPI {

    var result: Result<[StellarLedger], StellarLedgerServiceError> = .success([.mock])

    func ledgers(
        cursor: String?,
        order: Order?,
        limit: Int?,
        response: @escaping (Result<[StellarLedger], StellarLedgerServiceError>) -> Void
    ) {
        response(result)
    }
}
