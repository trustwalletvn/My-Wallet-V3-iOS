// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol CardActivationClientAPI: AnyObject {

    func activateCard(
        by id: String,
        url: String
    ) -> AnyPublisher<ActivateCardResponse.Partner, NabuNetworkError>
}
