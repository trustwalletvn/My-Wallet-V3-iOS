// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public enum LayoutUnit {
    private static let unit: CGFloat = 8.0
    public static let standard = unit
}

public enum Spacing {
    public static let interItem: CGFloat = LayoutUnit.standard / 2.0
    public static let standard: CGFloat = LayoutUnit.standard
    public static let outer: CGFloat = LayoutUnit.standard * 3
    public static let inner: CGFloat = LayoutUnit.standard * 2
}

public enum Sizing {
    public static let badge: CGFloat = LayoutUnit.standard * 4
}
