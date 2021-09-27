// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit
import RxSwift

final class CryptoFeeClient<FeeType: TransactionFee & Decodable> {

    // MARK: - Types

    private enum Endpoint {
        enum Fees {
            static var path: [String] {
                ["mempool", "fees", FeeType.cryptoType.pathComponent]
            }
        }
    }

    // MARK: - Private Properties

    private let requestBuilder: RequestBuilder
    private let networkAdapter: NetworkAdapterAPI

    var fees: AnyPublisher<FeeType, NetworkError> {
        let request = requestBuilder.get(
            path: Endpoint.Fees.path
        )!
        return networkAdapter.perform(request: request)
    }

    // MARK: - Init

    init(
        networkAdapter: NetworkAdapterAPI = resolve(),
        requestBuilder: RequestBuilder = resolve()
    ) {
        self.requestBuilder = requestBuilder
        self.networkAdapter = networkAdapter
    }
}
