// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine

protocol CustodialPaymentAccountClientAPI {
    func custodialPaymentAccount(
        for cryptoCurrency: CryptoCurrency
    ) -> AnyPublisher<PaymentAccount.Response, NabuNetworkError>
}
