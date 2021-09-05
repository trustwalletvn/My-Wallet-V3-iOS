// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A cache that evicts expired times after a specified amount of time
public final class Cache<Key: Hashable, Value> {

    private struct Item {
        let value: Value
        let expirationDate: Date
    }

    private var items = Atomic<[Key: Item]>([:])
    private let dateProvider: () -> Date
    private let entryLifetime: TimeInterval

    /// Default initalizer
    /// - Parameters:
    ///   - entryLifetime: An interval after which entries stored in the cache expire. Entries are removed from the cache after they expire. Defaults to `.infinity`, which means items do not expire.
    ///   - dateProvider: A function that creates new `Date` objects. Useful for Unit Testing.
    public init(
        entryLifetime: TimeInterval = .infinity,
        dateProvider: @escaping () -> Date = Date.init
    ) {
        self.dateProvider = dateProvider
        self.entryLifetime = entryLifetime
    }

    /// Stores a value for a given key.
    /// - Parameters:
    ///   - value: The value to be cached.
    ///   - key: An identifier that can be later used to retrieve the value.
    public func set(_ value: Value, forKey key: Key) {
        let expirationDate = dateProvider().addingTimeInterval(entryLifetime)
        items.mutate { $0[key] = Item(value: value, expirationDate: expirationDate) }
    }

    /// Retrieves a value, if any is stored, for a given key.
    /// - Parameter key: The identifier for the value to be retreived
    /// - Returns: `nil` if no value was stored for the passed-in `key` or if the value has expired. Otherwise, the stored value is returned.
    public func value(forKey key: Key) -> Value? {
        guard let entry = items.value[key] else {
            return nil
        }

        guard dateProvider() < entry.expirationDate else {
            // the value expired, forget it
            removeValue(forKey: key)
            return nil
        }

        return entry.value
    }

    /// Remove a value stored for a given key.
    /// - Parameter key: The identifier of the value to remove
    /// - Returns: The value removed or `nil` if no value was found for the passed-in key.
    @discardableResult
    public func removeValue(forKey key: Key) -> Value? {
        let item = items.value[key]
        items.mutate { $0[key] = nil }
        return item?.value
    }

    /// Remove all items in the cache
    public func removeAll() {
        items.mutate { $0 = [:] }
    }
}
