// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Higher level `Error` types should conform to this to enable mapping from `NetworkError` errors.
public protocol FromNetworkError: Error {

    /// Creates an `Error` from a given `NetworkError`.
    ///
    /// - Parameter networkError: A network error.
    static func from(_ networkError: NetworkError) -> Self
}

/// Decodable higher level `Error` types should conform to this to enable mapping from `NetworkError` errors.
public protocol FromNetworkErrorConvertible: FromNetworkError, Decodable {}
