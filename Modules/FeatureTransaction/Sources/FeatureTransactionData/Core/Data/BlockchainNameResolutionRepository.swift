// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import FeatureTransactionDomain
import NetworkKit

final class BlockchainNameResolutionRepository: BlockchainNameResolutionRepositoryAPI {

    // MARK: - Private properties

    private let client: BlockchainNameResolutionClientAPI

    // MARK: - Setup

    init(client: BlockchainNameResolutionClientAPI = DIKit.resolve()) {
        self.client = client
    }

    // MARK: - BlockchainNameResolutionRepositoryAPI

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolution, NetworkError> {
        client.resolve(domainName: domainName, currency: currency)
            .map(DomainResolution.init)
            .eraseToAnyPublisher()
    }
}
