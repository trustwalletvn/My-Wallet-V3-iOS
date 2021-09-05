// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformKit

final class MockDeepLinkHandler: DeepLinkHandling {
    var handleValue: (String, [DeepLinkRoute])!

    func handle(deepLink: String, supportedRoutes: [DeepLinkRoute]) {
        handleValue = (deepLink, supportedRoutes)
    }
}
