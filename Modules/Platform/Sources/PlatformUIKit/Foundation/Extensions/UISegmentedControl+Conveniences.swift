// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import UIKit

extension UISegmentedControl {

    public func setBackgroundColor(
        _ backgroundColor: UIColor?,
        for state: UIControl.State,
        barMetrics: UIBarMetrics
    ) {
        let image: UIImage? = backgroundColor
            .flatMap {
                .image(color: $0, size: .edge(1))
            }
        setBackgroundImage(
            image,
            for: state,
            barMetrics: barMetrics
        )
    }

    public func setDividerColor(
        _ dividerColor: UIColor?,
        forLeftSegmentState leftState: UIControl.State,
        rightSegmentState rightState: UIControl.State,
        barMetrics: UIBarMetrics
    ) {
        let image: UIImage? = dividerColor
            .flatMap {
                .image(color: $0, size: .init(width: 0.5, height: 1.0))
            }
        setDividerImage(
            image,
            forLeftSegmentState: leftState,
            rightSegmentState: rightState,
            barMetrics: barMetrics
        )
    }
}
