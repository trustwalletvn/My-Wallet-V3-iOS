// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol PaymentEligibleMethodsClientAPI: AnyObject {
    func eligiblePaymentMethods(for currency: String, currentTier: KYC.Tier, sddEligibleTier: Int?) -> Single<[PaymentMethodsResponse.Method]>
}
