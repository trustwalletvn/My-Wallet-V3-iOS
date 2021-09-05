// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension KeyedDecodingContainerProtocol {
    /// Decodes a `String` for the given key and converts it to a `Decimal`
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - parameter locale: The locale to be used when creating the `Decimal`.
    /// - returns: A `Decimal` value, if present for the given key and convertible.
    ///
    /// - throws: `DecodingError.dataCorruptedError` if the encountered `String` value
    ///   is not convertible to `Decimal`.
    ///   Plus, same as `decode(_ type: String.Type, forKey key: Self.Key) throws -> String`
    public func decodeDecimalFromString(
        forKey key: KeyedDecodingContainer<Self.Key>.Key,
        locale: Locale = .Posix
    ) throws -> Decimal {
        let stringValue = try decode(String.self, forKey: key)
        guard let value = Decimal(string: stringValue, locale: .Posix) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Can't convert to Decimal"
            )
        }
        return value
    }

    /// Decodes a `String` for the given key and converts it to a `Decimal`, if present.
    ///
    /// This method returns `nil` if the container does not have a value
    /// associated with `key`, or if the value is null.
    ///
    /// - parameter key: The key that the decoded value is associated with.
    /// - returns: A `Decimal`, or `nil` if the `Decoder` does not have an
    ///   entry associated with the given key, or if the value is a null value.
    ///
    /// - throws: `DecodingError.dataCorruptedError` if an encountered `String` value
    ///   is not convertible to `Decimal`.
    ///   Plus, same as `func decodeIfPresent(_ type: String.Type, forKey key: Self.Key) throws -> String?`
    public func decodeIfPresentDecimalFromString(
        forKey key: KeyedDecodingContainer<Self.Key>.Key,
        locale: Locale = .Posix
    ) throws -> Decimal? {
        guard let stringValue = try decodeIfPresent(String.self, forKey: key) else {
            return nil
        }
        guard let value = Decimal(string: stringValue, locale: .Posix) else {
            throw DecodingError.dataCorruptedError(
                forKey: key,
                in: self,
                debugDescription: "Can't convert to Decimal"
            )
        }
        return value
    }
}
