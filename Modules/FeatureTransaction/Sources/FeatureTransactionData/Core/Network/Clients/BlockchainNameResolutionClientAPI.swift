// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import DIKit
import NetworkKit

protocol BlockchainNameResolutionClientAPI {

    func resolve(
        domainName: String,
        currency: String
    ) -> AnyPublisher<DomainResolutionResponse, NetworkError>
}
