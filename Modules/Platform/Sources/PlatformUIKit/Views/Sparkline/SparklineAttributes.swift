// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct SparklineAttributes {

    /// The width of the path drawn
    public let lineWidth: CGFloat

    /// Dictates whether the line is curved and uses control points. Defaults
    /// to `false`.
    public let smoothing: Bool

    /// The size of the containing view
    public let size: CGSize

    /// The width of the final `Sparkline`
    public var width: CGFloat {
        size.width + (lineWidth / 2)
    }

    /// The height of the final `Sparkline`
    public var height: CGFloat {
        size.height + (lineWidth / 2)
    }

    // MARK: - Init

    public init(size: CGSize, lineWidth: CGFloat = 2.0, smoothing: Bool = false) {
        self.size = size
        self.lineWidth = lineWidth
        self.smoothing = smoothing
    }
}
