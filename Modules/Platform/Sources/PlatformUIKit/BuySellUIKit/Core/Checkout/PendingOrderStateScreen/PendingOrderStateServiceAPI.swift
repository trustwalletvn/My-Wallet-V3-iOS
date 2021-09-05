// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit
import RxRelay
import RxSwift
import ToolKit

public enum PendingOrderState {
    case pending(OrderDetails)
    case completed
    case upgrade
}

public protocol PendingOrderStateAPI {
    var stateRelay: PublishRelay<PendingOrderState> { get }
}

public protocol URLEmitterAPI {
    var tapRelay: PublishRelay<URL> { get }
}

public typealias PendingOrderRoutingInteracting = PendingOrderStateAPI &
    RoutingPreviousStateEmitterAPI &
    URLEmitterAPI
