// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// Interface for NSUbiquitousKeyValueStore
public protocol UbiquitousKeyValueStore {
    func set(_ aDictionary: [String: Any]?, forKey aKey: String)
    func dictionary(forKey aKey: String) -> [String: Any]?
    func synchronize() -> Bool
}

extension NSUbiquitousKeyValueStore: UbiquitousKeyValueStore {}
