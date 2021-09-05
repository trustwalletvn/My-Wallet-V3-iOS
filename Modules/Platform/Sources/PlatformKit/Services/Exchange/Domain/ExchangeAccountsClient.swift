// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift

protocol ExchangeAccountsProviderClientAPI {
    func exchangeAddress(with currency: CryptoCurrency) -> Single<CryptoExchangeAddressResponse>
}

protocol ExchangeAccountsClientAPI: ExchangeAccountsProviderClientAPI {}

final class ExchangeAccountsClient: ExchangeAccountsClientAPI {

    enum ExchangeAccountsClientError {
        /// Two factor authentication required
        case twoFactorRequired
    }

    private enum Path {
        static let exchangeAddress = ["payments", "accounts", "linked"]
    }

    // MARK: - Properties

    private let networkAdapter: NetworkAdapterAPI
    private let requestBuilder: RequestBuilder

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    // MARK: - ExchangeAccountsClientAPI

    func exchangeAddress(with currency: CryptoCurrency) -> Single<CryptoExchangeAddressResponse> {
        let model = CryptoExchangeAddressRequest(currency: currency)
        let request = requestBuilder.put(
            path: Path.exchangeAddress,
            body: try? JSONEncoder().encode(model),
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
}
