// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import AnalyticsKit

/// Announcement that can be dismissed using `X` or a secondary button
public protocol DismissibleAnnouncement: Announcement {

    /// A recorder that caches the information of the announcements
    /// either in-memory or on disk using [AnnouncementRecorder](x-source-tag://AnnouncementRecorder).
    var recorder: AnnouncementRecorder { get }

    /// A key that uniquely identifies the announcement in [AnnouncementRecorder](x-source-tag://AnnouncementRecorder).
    var key: AnnouncementRecord.Key { get }

    /// The category of the announcement (i.e one-time / persistent / periodic)
    var category: AnnouncementRecord.Category { get }

    /// Returns `true` if the announcement was recorded as dismissed and should not be shown
    var isDismissed: Bool { get }

    /// A dismiss action for announcement, called upon tapping `X` (dismiss button)
    var dismiss: CardAnnouncementAction { get }

    /// An analytics event for dismissal
    var dismissAnalyticsEvent: AnalyticsEvents.Announcement { get }
}

extension DismissibleAnnouncement {
    public var key: AnnouncementRecord.Key { type.key }
    public var dismissAnalyticsEvent: AnalyticsEvents.Announcement {
        .cardDismissed(type: type)
    }
}
