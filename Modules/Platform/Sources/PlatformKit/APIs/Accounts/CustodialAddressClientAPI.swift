// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

protocol CustodialPaymentAccountClientAPI {
    func custodialPaymentAccount(for cryptoCurrency: CryptoCurrency) -> Single<PaymentAccount.Response>
}
