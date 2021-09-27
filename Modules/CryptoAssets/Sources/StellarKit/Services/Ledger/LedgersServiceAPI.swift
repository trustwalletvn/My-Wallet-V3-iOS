// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift
import stellarsdk

protocol LedgersServiceAPI: AnyObject {
    func ledgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?,
        response: @escaping (Result<[StellarLedger], StellarLedgerServiceError>) -> Void
    )
}

extension LedgersServiceAPI {
    func ledgers(
        cursor: String?,
        order: stellarsdk.Order?,
        limit: Int?
    ) -> Single<StellarLedger> {
        Single<StellarLedger>.create(weak: self) { (self, observer) -> Disposable in
            self.ledgers(cursor: cursor, order: order, limit: limit) { result in
                switch result {
                case .success(let value):
                    if let ledger = value.first {
                        observer(.success(ledger))
                    } else {
                        observer(.error(StellarLedgerServiceError.unknown))
                    }
                case .failure(let error):
                    observer(.error(error))
                }
            }
            return Disposables.create()
        }
    }
}

enum StellarLedgerServiceError: Error {
    case unknown
    case sdkError(Error)
}
