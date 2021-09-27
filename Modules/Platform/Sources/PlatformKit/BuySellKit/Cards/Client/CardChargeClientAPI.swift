// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol CardChargeClientAPI: AnyObject {

    func chargeCard(by id: String) -> AnyPublisher<Void, NabuNetworkError>
}
