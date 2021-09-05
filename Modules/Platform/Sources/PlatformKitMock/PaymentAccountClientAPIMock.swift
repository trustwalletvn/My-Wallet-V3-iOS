// Copyright © Blockchain Luxembourg S.A. All rights reserved.

@testable import PlatformKit
import RxSwift

class SimpleBuyPaymentAccountClientAPIMock: PaymentAccountClientAPI {
    var mockResponse: PaymentAccountResponse! = .mock(with: .GBP, agent: .fullMock)

    func paymentAccount(for currency: FiatCurrency) -> Single<PlatformKit.PaymentAccount.Response> {
        Single.just(mockResponse)
    }
}
