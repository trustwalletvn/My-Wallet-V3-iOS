// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

extension AnalyticsEvents.New {
    public enum Withdraw: AnalyticsEvent {

        public var type: AnalyticsEventType {
            .nabu
        }

        case withdrawViewed
    }
}
