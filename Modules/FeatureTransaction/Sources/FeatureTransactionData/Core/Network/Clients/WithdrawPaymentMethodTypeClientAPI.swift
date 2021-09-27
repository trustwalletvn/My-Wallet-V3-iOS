// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxSwift

protocol WithdrawPaymentMethodTypeClientAPI {
    func fetchWithdrawPaymentMethodTypes(for currency: FiatCurrency) -> Single<PaymentMethodType>
}
