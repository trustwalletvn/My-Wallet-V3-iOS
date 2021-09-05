// Copyright © Blockchain Luxembourg S.A. All rights reserved.

/// A content that can populate a view
public enum ViewContent {

    /// Label
    case label(LabelContent)

    /// Image
    case image(ImageViewContent)

    /// None
    case none

    public var hasContent: Bool {
        if case .none = self { return false }
        return true
    }
}
