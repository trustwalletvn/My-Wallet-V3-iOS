// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Encodable {
    public var dictionary: [String: Any] {
        guard let data = try? JSONEncoder().encode(self) else {
            return [:]
        }
        return (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] ?? [:]
    }

    public func encode() throws -> Data {
        let encoder = JSONEncoder()
        return try encoder.encode(self)
    }

    public func encodeToString(encoding: String.Encoding) throws -> String {
        let encodedData = try encode()
        guard let string = String(data: encodedData, encoding: encoding) else {
            throw EncodingError.invalidValue(
                encodedData,
                EncodingError.Context(
                    codingPath: [],
                    debugDescription: "Could not create string with given encoding."
                )
            )
        }
        return string
    }

    public func toDictionary() throws -> [String: Any] {
        guard let data = try? encode(), let dictionary = try JSONSerialization.jsonObject(
            with: data,
            options: .allowFragments
        ) as? [String: Any] else {
            throw NSError(domain: "Encodable", code: 0, userInfo: nil)
        }
        return dictionary
    }

    public func tryToEncode(
        encoding: String.Encoding,
        onSuccess: (String) -> Void,
        onError: () -> Void
    ) {
        do {
            let encodedData = try encode()
            guard let string = String(data: encodedData, encoding: encoding) else {
                onError()
                return
            }
            onSuccess(string)
        } catch {
            onError()
        }
    }
}
