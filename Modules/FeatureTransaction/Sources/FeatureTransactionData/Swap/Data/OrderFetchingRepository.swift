// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import PlatformKit

final class OrderFetchingRepository: OrderFetchingRepositoryAPI {

    // MARK: - Properties

    private let client: OrderFetchingClientAPI

    // MARK: - Setup

    init(client: OrderFetchingClientAPI = resolve()) {
        self.client = client
    }

    // MARK: - OrderFetchingRepositoryAPI

    func fetchTransaction(
        with transactionId: String
    ) -> AnyPublisher<SwapActivityItemEvent, NabuNetworkError> {
        client.fetchTransaction(with: transactionId)
    }
}
