// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit
import PlatformKit
import ToolKit

extension AnalyticsEvents {
    public enum Announcement: AnalyticsEvent {
        case cardShown(type: AnnouncementType)
        case cardActioned(type: AnnouncementType)
        case cardDismissed(type: AnnouncementType)

        public var name: String {
            switch self {
            // User is shown a particular onboarding card
            case .cardShown:
                return "card_shown"
            // User interacts with a given card
            case .cardActioned:
                return "card_actioned"
            // User dismisses a given card
            case .cardDismissed:
                return "card_dismissed"
            }
        }

        public var params: [String: String]? {
            ["card_title": type.rawValue]
        }

        private var type: AnnouncementType {
            switch self {
            case .cardShown(type: let type):
                return type
            case .cardActioned(type: let type):
                return type
            case .cardDismissed(type: let type):
                return type
            }
        }
    }
}
