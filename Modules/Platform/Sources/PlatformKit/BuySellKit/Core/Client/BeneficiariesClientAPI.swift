// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol BeneficiariesClientAPI: AnyObject {
    var beneficiaries: AnyPublisher<[BeneficiaryResponse], NabuNetworkError> { get }

    func deleteBank(by id: String) -> AnyPublisher<Void, NabuNetworkError>
}
