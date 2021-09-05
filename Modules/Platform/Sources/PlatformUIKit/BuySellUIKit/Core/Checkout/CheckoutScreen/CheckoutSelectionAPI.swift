// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import RxRelay
import ToolKit

public enum CheckoutDataAction {
    case cancel(CheckoutData)
    case bankTransferDetails(CheckoutData)
    case confirm(CheckoutData, isOrderNew: Bool)
}

public protocol CheckoutSelectionAPI {
    var actionRelay: PublishRelay<CheckoutDataAction> { get }
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }
}

public typealias CheckoutRoutingInteracting = CheckoutSelectionAPI & RoutingPreviousStateEmitterAPI
