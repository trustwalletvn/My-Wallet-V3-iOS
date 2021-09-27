// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import PlatformKit

final class AvailablePairsRepository: AvailablePairsRepositoryAPI {

    // MARK: - AvailablePairsRepositoryAPI

    var availableOrderPairs: AnyPublisher<[OrderPair], NabuNetworkError> {
        client.availableOrderPairs
            .map(\.pairs)
            .map { $0.compactMap(OrderPair.init(rawValue:)) }
            .eraseToAnyPublisher()
    }

    // MARK: - Private properties

    private let client: AvailablePairsClientAPI

    // MARK: - Setup

    init(client: AvailablePairsClientAPI = resolve()) {
        self.client = client
    }
}
