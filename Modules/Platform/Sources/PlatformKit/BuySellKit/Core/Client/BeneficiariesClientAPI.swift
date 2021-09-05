// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol BeneficiariesClientAPI: AnyObject {
    var beneficiaries: Single<[BeneficiaryResponse]> { get }

    func deleteBank(by id: String) -> Completable
}
