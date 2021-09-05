// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol PaymentAccountClientAPI: AnyObject {

    /// Fetch the Payment Account information for the given currency.
    func paymentAccount(for currency: FiatCurrency) -> Single<PlatformKit.PaymentAccount.Response>
}
