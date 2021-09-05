// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import NetworkKit
import RxSwift

public protocol SwapActivityClientAPI {
    func fetchActivity(
        from date: Date,
        fiatCurrency: String?,
        cryptoCurrency: String?,
        limit: Int
    ) -> Single<[SwapActivityItemEvent]>
}

public typealias SwapClientAPI = SwapActivityClientAPI

final class SwapClient: SwapClientAPI {

    private enum Parameter {
        static let before = "before"
        static let fiatCurrency = "userFiatCurrency"
        static let cryptoCurrency = "currency"
        static let limit = "limit"
    }

    private enum Path {
        static let activity = ["trades", "unified"]
    }

    // MARK: - Properties

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

    // MARK: - SwapActivityClientAPI

    func fetchActivity(
        from date: Date,
        fiatCurrency: String?,
        cryptoCurrency: String?,
        limit: Int
    ) -> Single<[SwapActivityItemEvent]> {
        var parameters = [
            URLQueryItem(
                name: Parameter.before,
                value: DateFormatter.iso8601Format.string(from: date)
            ),
            URLQueryItem(
                name: Parameter.limit,
                value: "\(limit)"
            )
        ]
        if let fiatCurrency = fiatCurrency {
            parameters.append(
                URLQueryItem(
                    name: Parameter.fiatCurrency,
                    value: fiatCurrency
                )
            )
        }
        if let cryptoCurrency = cryptoCurrency {
            parameters.append(
                URLQueryItem(
                    name: Parameter.cryptoCurrency,
                    value: cryptoCurrency
                )
            )
        }

        let path = Path.activity
        let request = requestBuilder.get(
            path: path,
            parameters: parameters,
            authenticated: true
        )!
        return networkAdapter
            .perform(
                request: request,
                errorResponseType: NabuNetworkError.self
            )
    }
}
