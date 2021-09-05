// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A persistent announcement is an action driven announcement.
/// This announcement keeps showing until the user has completed the relevant action.
/// Once the user has completed the action the announcement will not be displayed again.
public protocol PersistentAnnouncement: Announcement {}
extension PersistentAnnouncement {

    /// Default the category to persistent
    public var category: AnnouncementRecord.Category { .persistent }
}
