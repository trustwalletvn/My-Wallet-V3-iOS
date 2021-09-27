// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import PlatformKit

protocol AvailablePairsClientAPI {

    var availableOrderPairs: AnyPublisher<AvailableTradingPairsResponse, NabuNetworkError> { get }
}
