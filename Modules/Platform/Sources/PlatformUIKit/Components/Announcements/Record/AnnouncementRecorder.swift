// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import PlatformKit
import ToolKit

/// A class that records dismiss actions taken by the user when dismissing an announcement.
/// We record the dismissal so that it wouldn't be shown again in case it has already been shown once.
/// - Tag: `AnnouncementRecorder`
public final class AnnouncementRecorder {

    // MARK: - Properties

    private let cache: CacheSuite
    private let errorRecorder: ErrorRecording

    /// Key subscript for an entry
    public subscript(key: AnnouncementRecord.Key) -> Entry {
        Entry(errorRecorder: errorRecorder, recorder: self, key: key)
    }

    // MARK: - Setup

    public init(
        cache: CacheSuite = resolve(),
        errorRecorder: ErrorRecording
    ) {
        self.errorRecorder = errorRecorder
        self.cache = cache
    }
}

// MARK: - Legacy

extension AnnouncementRecorder {

    /// Resets the announcements entirely by clearing any announcements from user defaults
    public static func reset() {
        let cacheSuite: CacheSuite = resolve()
        cacheSuite
            .dictionaryRepresentation()
            .keys
            .filter { key in
                key.hasPrefix("announcement-")
            }
            .forEach {
                cacheSuite.removeObject(forKey: $0)
            }
    }
}

// MARK: - Entry

extension AnnouncementRecorder {

    /// Cached entry for which announcement dismissal is recorded
    public final class Entry: Hashable, Equatable {

        // MARK: - Properties

        /// Returns the display state as per announcement
        /// If the record was not kept in cache - it's safe to assume it's a new record
        var displayState: AnnouncementRecord.DisplayState {
            value(for: key)?.displayState ?? .show
        }

        private let errorRecorder: ErrorRecording
        private unowned let recorder: AnnouncementRecorder

        /// The key to the cache suite
        private let key: AnnouncementRecord.Key

        // MARK: - Setup

        init(
            errorRecorder: ErrorRecording,
            recorder: AnnouncementRecorder,
            key: AnnouncementRecord.Key
        ) {
            self.errorRecorder = errorRecorder
            self.recorder = recorder
            self.key = key
        }

        /// Marks the announcement as removed by keeping it in cache
        /// along with its category, dismissal date, and number of dismissals so far.
        /// - parameter category: the category of the announcement
        public func markRemoved(category: AnnouncementRecord.Category) {
            let record = AnnouncementRecord(state: .removed, category: category)
            save(record: record)
        }

        /// Marks the announcement as dismissed by keeping it in cache
        /// along with its category, dismissal date, and number of dismissals so far.
        /// - parameter category: the category of the announcement
        func markDismissed(category: AnnouncementRecord.Category) {

            // Calculate number of dismissals
            let dismissalCount: Int
            switch value(for: key)?.state {
            case .some(.dismissed(on: _, count: let count)):
                dismissalCount = count + 1
            default:
                dismissalCount = 1
            }

            // Prepare a record with the current time as dismissal date and count of dismissals
            let record = AnnouncementRecord(
                state: .dismissed(on: Date(), count: dismissalCount),
                category: category
            )
            save(record: record)
        }

        // MARK: - Accessors

        private func save(record: AnnouncementRecord) {
            do {
                let data = try record.encode()
                recorder.cache.set(data, forKey: key.string)
            } catch {
                errorRecorder.error(error)
            }
        }

        private func value(for key: AnnouncementRecord.Key) -> AnnouncementRecord? {
            guard let data = recorder.cache.data(forKey: key.string) else {
                return nil
            }
            return try? data.decode(to: AnnouncementRecord.self)
        }

        // MARK: Hashable

        public func hash(into hasher: inout Hasher) {
            hasher.combine(key.string)
        }

        // MARK: - Equatable

        public static func == (lhs: AnnouncementRecorder.Entry, rhs: AnnouncementRecorder.Entry) -> Bool {
            lhs.key.string == rhs.key.string
        }
    }
}
