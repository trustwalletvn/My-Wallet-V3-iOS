// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit
import ToolKit

public protocol PaymentAccountsServiceAPI {

    func fetchPaymentAccounts(
        for currency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentAccount], NetworkError>
}

final class PaymentAccountsService: PaymentAccountsServiceAPI {

    let client: PlatformKit.PaymentMethodsServiceAPI // TODO: this should become a client

    init(client: PlatformKit.PaymentMethodsServiceAPI = resolve()) {
        self.client = client
    }

    func fetchPaymentAccounts(
        for currency: CryptoCurrency,
        amount: MoneyValue
    ) -> AnyPublisher<[PaymentAccount], NetworkError> {
        // TODO: implement me again when Lorenzo has finished working on the new API
        client.paymentMethods
            .asPublisher()
            .mapError { error in
                guard let error = error as? NetworkError else {
                    return NetworkError.authentication(error)
                }
                return error
            }
            .map { paymentMethods in
                paymentMethods.map { paymentMethod in
                    PaymentAccount(
                        paymentMethod: paymentMethod,
                        linkedAccount: nil // TODO: add linked account when Lorenzo finishes working on new API
                    )
                }
            }
            .eraseToAnyPublisher()
    }
}
