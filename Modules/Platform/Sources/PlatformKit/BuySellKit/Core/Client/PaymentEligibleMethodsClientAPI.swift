// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol PaymentEligibleMethodsClientAPI: AnyObject {
    func eligiblePaymentMethods(
        for currency: String,
        currentTier: KYC.Tier,
        sddEligibleTier: Int?
    ) -> AnyPublisher<[PaymentMethodsResponse.Method], NabuNetworkError>
}
