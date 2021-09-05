// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import DIKit
import ToolKit

public final class EventCache {

    // MARK: - Types

    public enum Key: String, CaseIterable {
        case hasShownIntroScreen = "simple-buy-intro-screen-shown"
        case hasShownBuyScreen = "simple-buy-buy-screen-shown"
    }

    // MARK: - Subscript

    /// Key subscript for an entry
    public subscript(key: Key) -> Bool {
        get {
            cacheSuite.bool(forKey: key.rawValue)
        }
        set {
            cacheSuite.set(newValue, forKey: key.rawValue)
        }
    }

    // MARK: - Private Properties

    private let cacheSuite: CacheSuite

    // MARK: - Setup

    init(cacheSuite: CacheSuite = resolve()) {
        self.cacheSuite = cacheSuite
    }

    public func reset() {
        Key.allCases.forEach { cacheSuite.removeObject(forKey: $0.rawValue) }
    }
}
