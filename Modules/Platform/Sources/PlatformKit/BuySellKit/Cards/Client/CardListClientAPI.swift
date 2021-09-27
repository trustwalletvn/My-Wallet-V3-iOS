// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Combine
import NetworkKit

public protocol CardListClientAPI: AnyObject {

    var cardList: AnyPublisher<[CardPayload], NabuNetworkError> { get }
}
