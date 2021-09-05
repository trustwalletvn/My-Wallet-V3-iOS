// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// Announcement that can be totally removed. Typically used for one-time announcements.
public protocol RemovableAnnouncement: DismissibleAnnouncement {
    func markRemoved()
}

extension RemovableAnnouncement {

    /// Marks the announcement as removed, so that it will never appear again.
    public func markRemoved() {
        recorder[key].markRemoved(category: category)
    }
}
