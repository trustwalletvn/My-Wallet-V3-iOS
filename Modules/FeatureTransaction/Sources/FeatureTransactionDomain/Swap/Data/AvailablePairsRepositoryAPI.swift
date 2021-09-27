// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

public protocol AvailablePairsRepositoryAPI {

    var availableOrderPairs: AnyPublisher<[OrderPair], NabuNetworkError> { get }
}
