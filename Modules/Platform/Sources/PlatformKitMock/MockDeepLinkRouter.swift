// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class MockDeepLinkRouter: DeepLinkRouting {
    var underlyingRouteIfNeeded: Bool = false
    var routeIfNeededCalled = false

    func routeIfNeeded() -> Bool {
        routeIfNeededCalled = true
        return underlyingRouteIfNeeded
    }
}
