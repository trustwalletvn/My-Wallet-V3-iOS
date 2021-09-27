// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import FeatureKYCUI
import PlatformKit

/// The main `DeepLinkRouting`
final class DeepLinkRouter: DeepLinkRouting {

    private let routers: [DeepLinkRouting]

    init(routers: [DeepLinkRouting] = [
        KYCDeepLinkRouter(),
        KYCResubmitIdentityRouter(),
        ExchangeDeepLinkRouter(),
        BitPayLinkRouter()
    ]) {
        self.routers = routers
    }

    @discardableResult
    func routeIfNeeded() -> Bool {
        routers.map { $0.routeIfNeeded() }.first { $0 } ?? false
    }
}
