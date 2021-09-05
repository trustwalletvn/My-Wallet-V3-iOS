// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol DeepLinkHandling {
    func handle(deepLink: String)
    func handle(deepLink: String, supportedRoutes: [DeepLinkRoute])
}

extension DeepLinkHandling {
    public func handle(deepLink: String) {
        handle(deepLink: deepLink, supportedRoutes: DeepLinkRoute.allCases)
    }
}
