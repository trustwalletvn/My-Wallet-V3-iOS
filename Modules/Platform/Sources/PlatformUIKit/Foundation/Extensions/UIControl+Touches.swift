// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

extension UIControl {
    public func addTargetForTouchDown(_ target: Any?, selector: Selector) {
        addTarget(target, action: selector, for: .touchDown)
    }

    public func addTargetForTouchUp(_ target: Any?, selector: Selector) {
        addTarget(target, action: selector, for: [.touchCancel, .touchUpInside, .touchUpOutside])
    }
}
