// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension CGSize {
    /// Returns a square `CGSize` with the given `edge`.
    public static func edge(_ edge: CGFloat) -> CGSize {
        CGSize(edge: edge)
    }

    public init(edge: CGFloat) {
        self.init(width: edge, height: edge)
    }
}
