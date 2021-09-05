// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: UIView {
    public var visibility: Binder<Visibility> {
        Binder(base) { view, visibility in
            view.alpha = visibility.defaultAlpha
            view.isUserInteractionEnabled = visibility == .visible
        }
    }
}
