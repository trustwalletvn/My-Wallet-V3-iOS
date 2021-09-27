// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxSwift

/// `MultiActionViewPresenting` represents a `MultiActionView`.
public protocol MultiActionViewPresenting {
    /// The view model for the `SegmentedView`
    var segmentedViewModel: SegmentedViewModel { get }
}

public final class MultiActionViewPresenter: MultiActionViewPresenting {

    public let segmentedViewModel: SegmentedViewModel

    // MARK: - Setup

    public init(segmentedViewModel: SegmentedViewModel) {
        self.segmentedViewModel = segmentedViewModel
    }
}
