// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

/// A box the wraps any content weakly. Handy for enums with an associated value that we do not wish to retain
public struct UnretainedContentBox<T: AnyObject> {
    public weak var value: T?

    public init(_ value: T?) {
        self.value = value
    }
}
