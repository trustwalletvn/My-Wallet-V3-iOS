// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension URL {

    /// Returns the query arguments of this URL as a key-value pair
    public var queryArgs: [String: String] {
        query?.queryArgs ?? [:]
    }
}
