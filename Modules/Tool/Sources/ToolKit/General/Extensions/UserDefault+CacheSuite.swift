// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A suite that can cache values for any purpose
public protocol CacheSuite {

    // MARK: - Getters

    func dictionaryRepresentation() -> [String: Any]

    func object(forKey key: String) -> Any?

    /// Returns a boolean value for key
    func bool(forKey key: String) -> Bool

    /// Returns a boolean value for key
    func integer(forKey key: String) -> Int

    /// Returns a boolean value for key
    func float(forKey key: String) -> Float

    /// Returns a boolean value for key
    func double(forKey key: String) -> Double

    /// Returns a String value for key
    func string(forKey key: String) -> String?

    /// Returns data value for key
    func data(forKey key: String) -> Data?

    // MARK: - Setters

    /// Keeps Bool value for key
    func set(_ value: Bool, forKey key: String)

    /// Keeps Int value for key
    func set(_ value: Int, forKey key: String)

    /// Keeps Float value for key
    func set(_ value: Float, forKey key: String)

    /// Keeps Double value for key
    func set(_ value: Double, forKey key: String)

    /// Keeps `Any?` value for key
    func set(_ value: Any?, forKey key: String)

    /// Keeps each key-value pair
    func register(defaults registrationDictionary: [String: Any])

    // MARK: - Removal

    /// Removes an object
    func removeObject(forKey key: String)
}

extension UserDefaults: CacheSuite {}

/// In-memory cache suite - provides a mocking functionality for user defaults
public class MemoryCacheSuite: CacheSuite {

    // MARK: - Properties

    private var cache: [String: Any]

    // MARK: - Setup

    public init(cache: [String: Any] = [:]) {
        self.cache = cache
    }

    // MARK: - Getters

    public func dictionaryRepresentation() -> [String: Any] {
        cache
    }

    public func object(forKey key: String) -> Any? {
        cache[key]
    }

    public func bool(forKey key: String) -> Bool {
        cache[key] as? Bool ?? false
    }

    public func integer(forKey key: String) -> Int {
        cache[key] as? Int ?? 0
    }

    public func float(forKey key: String) -> Float {
        cache[key] as? Float ?? 0
    }

    public func double(forKey key: String) -> Double {
        cache[key] as? Double ?? 0
    }

    public func string(forKey key: String) -> String? {
        cache[key] as? String
    }

    public func data(forKey key: String) -> Data? {
        cache[key] as? Data
    }

    // MARK: - Setters

    public func register(defaults registrationDictionary: [String: Any]) {
        registrationDictionary.forEach {
            cache[$0.key] = $0.value
        }
    }

    public func set(_ value: Bool, forKey key: String) {
        cache[key] = value
    }

    public func set(_ value: Int, forKey key: String) {
        cache[key] = value
    }

    public func set(_ value: Float, forKey key: String) {
        cache[key] = value
    }

    public func set(_ value: Double, forKey key: String) {
        cache[key] = value
    }

    public func set(_ value: Any?, forKey key: String) {
        cache[key] = value
    }

    // MARK: - Removal

    public func removeObject(forKey key: String) {
        cache[key] = nil
    }
}
