// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import PlatformKit
import ToolKit

typealias InterestDataKitAPIClient =
    InterestAccountEligibilityClientAPI &
    InterestAccountLimitsClientAPI &
    InterestAccountRateClientAPI &
    InterestAccountBalanceClientAPI

final class APIClient: InterestDataKitAPIClient {

    private enum Path {
        static let interestEligibility = ["eligible", "product", "savings"]
        static let balance = ["accounts", "savings"]
        static let rate = ["savings", "rates"]
        static let limits = ["savings", "limits"]
    }

    private enum Parameter {
        static let currency = "currency"
        static let ccy = "ccy"
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    // MARK: - Setup

    init(
        networkAdapter: NetworkAdapterAPI = resolve(tag: DIKitContext.retail),
        requestBuilder: RequestBuilder = resolve(tag: DIKitContext.retail)
    ) {
        self.networkAdapter = networkAdapter
        self.requestBuilder = requestBuilder
    }

    func fetchBalanceWithFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountBalanceResponse?, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.balance,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountEligibilityResponse()
        -> AnyPublisher<InterestEligibilityResponse, NabuNetworkError>
    {
        let request = requestBuilder.get(
            path: Path.interestEligibility,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountLimitsResponseForFiatCurrency(
        _ fiatCurrency: FiatCurrency
    ) -> AnyPublisher<InterestAccountLimitsResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.currency,
                value: fiatCurrency.code
            )
        ]
        let request = requestBuilder.get(
            path: Path.limits,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }

    func fetchInterestAccountRateForCurrencyCode(
        _ currencyCode: String
    ) -> AnyPublisher<InterestAccountRateResponse, NabuNetworkError> {
        let parameters = [
            URLQueryItem(
                name: Parameter.ccy,
                value: currencyCode
            )
        ]
        let request = requestBuilder.get(
            path: Path.rate,
            parameters: parameters,
            authenticated: true
        )!

        return networkAdapter
            .perform(request: request)
    }
}
