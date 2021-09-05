// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Dictionary {
    public func compactMapValues<T>(_ transform: (Value) throws -> T?) rethrows -> [Key: T] {
        try reduce(into: [Key: T]()) { result, element in
            if let value = try transform(element.value) {
                result[element.key] = value
            }
        }
    }

    /// Merges the given dictionary into this dictionary. In case of duplicate keys, uses the value from the given dictionary.
    public mutating func merge(_ other: [Key: Value]) {
        merge(other) { _, rhs in
            rhs
        }
    }

    /// Creates a dictionary by merging the given dictionary into this dictionary. In case of duplicate keys, uses the value from the given dictionary.
    public func merging(_ other: [Key: Value]) -> [Key: Value] {
        merging(other) { _, rhs in
            rhs
        }
    }
}

/// Convenience alternative to `merge`
public func += <Key, Value>(
    lhs: inout [Key: Value],
    rhs: [Key: Value]
) {
    lhs.merge(rhs)
}

/// Convenience alternative to `merging`
public func + <Key, Value>(
    lhs: [Key: Value],
    rhs: [Key: Value]
) -> [Key: Value] {
    lhs.merging(rhs)
}

extension Dictionary where Key == String, Value == [String: Any] {
    /// Cast the `[String: [String: Any]]` objects in this Dictionary to instances of `Type`
    ///
    /// - Parameter type: the type
    /// - Returns: the casted array
    public func decodeJSONObjects<T: Codable>(type: T.Type) -> [String: T] {
        let jsonDecoder = JSONDecoder()
        return compactMapValues { value -> T? in
            guard let data = try? JSONSerialization.data(withJSONObject: value, options: []) else {
                Logger.shared.warning("Failed to serialize dictionary.")
                return nil
            }

            do {
                return try jsonDecoder.decode(type.self, from: data)
            } catch {
                Logger.shared.error("Failed to decode \(error)")
            }

            return nil
        }
    }

    public func decodeJSONValues<T: Codable>(type: T.Type) -> [T] {
        decodeJSONObjects(type: type)
            .compactMap { tuple -> T? in
                let (_, value) = tuple
                return value
            }
    }
}
