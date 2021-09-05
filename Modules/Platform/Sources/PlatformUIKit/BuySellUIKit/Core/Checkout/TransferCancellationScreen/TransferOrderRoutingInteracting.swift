// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

public protocol TransferOrderRoutingInteracting: RoutingNextStateEmitterAPI, RoutingPreviousStateEmitterAPI {
    var analyticsRecorder: AnalyticsEventRecorderAPI { get }
}
