// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    enum Security: AnalyticsEvent {
        var type: AnalyticsEventType { .nabu }

        case accountPasswordChanged
        case changePinClicked
        case emailChangeClicked
        case biometricsUpdated(isEnabled: Bool)
        case recoveryPhraseShown
        case syncMyWidgetPortfolioUpdated(isEnabled: Bool)
    }
}
