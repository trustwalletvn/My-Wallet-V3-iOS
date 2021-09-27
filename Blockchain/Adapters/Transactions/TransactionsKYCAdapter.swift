// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionUI
import PlatformKit

final class TransactionsKYCAdapter {

    private let kycTiersService: KYCTiersServiceAPI

    init(
        kycTiersService: KYCTiersServiceAPI = resolve()
    ) {
        self.kycTiersService = kycTiersService
    }
}

extension TransactionsKYCAdapter: FeatureTransactionUI.KYCSDDServiceAPI {

    func checkSimplifiedDueDiligenceEligibility() -> AnyPublisher<Bool, Never> {
        kycTiersService.checkSimplifiedDueDiligenceEligibility()
    }

    func checkSimplifiedDueDiligenceVerification() -> AnyPublisher<Bool, Never> {
        kycTiersService.checkSimplifiedDueDiligenceVerification(pollUntilComplete: true)
    }
}
