// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: CALayer {
    public var borderColor: Binder<UIColor> {
        Binder(base) { layer, color in
            layer.borderColor = color.cgColor
        }
    }
}

extension Reactive where Base: CAShapeLayer {
    public var path: Binder<UIBezierPath?> {
        Binder(base) { layer, path in
            layer.path = path?.cgPath
        }
    }

    public var strokeColor: Binder<UIColor?> {
        Binder(base) { layer, color in
            layer.strokeColor = color?.cgColor
        }
    }

    public var fillColor: Binder<UIColor?> {
        Binder(base) { layer, color in
            layer.fillColor = color?.cgColor
        }
    }

    public var lineWidth: Binder<CGFloat> {
        Binder(base) { layer, lineWidth in
            layer.lineWidth = lineWidth
        }
    }
}
