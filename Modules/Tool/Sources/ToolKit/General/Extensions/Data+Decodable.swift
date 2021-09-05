// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Data {

    /// Data -> `Decodable` using the type `T: Decodable`
    public func decode<T: Decodable>(to type: T.Type) throws -> T {
        let decoded: T
        do {
            decoded = try JSONDecoder().decode(type, from: self)
        } catch {
            throw error
        }
        return decoded
    }
}

extension Decodable {
    public static func decode(data: Data) throws -> Self {
        let decoder = JSONDecoder()
        return try decoder.decode(Self.self, from: data)
    }
}
