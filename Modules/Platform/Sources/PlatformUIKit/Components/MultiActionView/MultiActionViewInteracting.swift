// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public protocol MultiActionViewInteracting {
    /// Items that can be selected in the `SegmentedView`.
    /// Each item has a closure that can be executed.
    var items: [SegmentedViewModel.Item] { get }
}
