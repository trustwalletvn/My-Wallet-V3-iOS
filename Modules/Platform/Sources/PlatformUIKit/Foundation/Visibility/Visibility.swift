// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// We used `Visibility` for hiding and showing
/// specific views. It's easier to read
public enum Visibility: Int {
    case hidden
    case visible

    public var defaultAlpha: CGFloat {
        switch self {
        case .hidden:
            return 0
        case .visible:
            return 1
        }
    }

    /// Returns the inverted alpha for visibility value
    public var invertedAlpha: CGFloat {
        1 - defaultAlpha
    }

    public var isHidden: Bool {
        self == .hidden ? true : false
    }

    public var inverted: Visibility {
        self == .hidden ? .visible : .hidden
    }
}
