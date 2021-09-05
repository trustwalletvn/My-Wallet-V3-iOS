// Copyright © Blockchain Luxembourg S.A. All rights reserved.

extension AnnouncementRecord {

    /// The category of the announcement
    public enum Category: String, Codable {
        case persistent
        case periodic
        case oneTime
    }
}
