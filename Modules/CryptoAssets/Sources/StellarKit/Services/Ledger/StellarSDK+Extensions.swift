// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import stellarsdk

extension stellarsdk.LedgersService: LedgersServiceAPI {
    func ledgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?,
        response: @escaping (Result<[StellarLedger], StellarLedgerServiceError>) -> Void
    ) {
        getLedgers(cursor: cursor, order: order, limit: limit) { result in
            switch result {
            case .success(let value):
                let result = value.records.map { $0.mapToStellarLedger() }
                response(.success(result))
            case .failure(let error):
                response(.failure(StellarLedgerServiceError.sdkError(error)))
            }
        }
    }
}

extension stellarsdk.LedgerResponse {
    func mapToStellarLedger() -> StellarLedger {
        StellarLedger(
            identifier: id,
            token: pagingToken,
            sequence: Int(sequenceNumber),
            transactionCount: successfulTransactionCount,
            operationCount: operationCount,
            closedAt: closedAt,
            totalCoins: totalCoins,
            baseFeeInStroops: baseFeeInStroops,
            baseReserveInStroops: baseReserveInStroops
        )
    }
}
