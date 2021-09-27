// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: UISegmentedControl {
    /// Background color of unselected items.
    public var backgroundColor: Binder<UIColor?> {
        Binder(base) { segmentedControl, fillColor in
            segmentedControl.setBackgroundColor(
                fillColor,
                for: .selected,
                barMetrics: .default
            )
        }
    }

    public var selectedTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        Binder(base) { segmentedControl, textAttributes in
            segmentedControl.setTitleTextAttributes(textAttributes, for: .selected)
        }
    }

    public var normalTextAttributes: Binder<[NSAttributedString.Key: Any]?> {
        Binder(base) { segmentedControl, textAttributes in
            segmentedControl.setTitleTextAttributes(textAttributes, for: .normal)
        }
    }

    public var dividerColor: Binder<UIColor?> {
        Binder(base) { segmentedControl, dividerColor in
            segmentedControl.setDividerColor(
                dividerColor,
                forLeftSegmentState: .normal,
                rightSegmentState: .normal,
                barMetrics: .default
            )
        }
    }
}
