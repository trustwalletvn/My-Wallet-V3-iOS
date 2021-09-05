// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension Sequence {
    public func map<T>(_ keyPath: KeyPath<Element, T>) -> [T] {
        map { $0[keyPath: keyPath] }
    }
}

extension Sequence where Iterator.Element: Hashable {
    public var unique: [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}
