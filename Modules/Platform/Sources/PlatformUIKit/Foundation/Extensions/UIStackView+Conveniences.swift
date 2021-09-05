// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

extension UIStackView {
    public func addBackgroundColor(_ color: UIColor) {
        let subview = UIView(frame: bounds)
        subview.backgroundColor = color
        subview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        insertSubview(subview, at: 0)
    }

    public func insertArrangedSubview(_ view: UIView, belowArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(view, at: $0.0 + 1)
            }
        }
    }

    public func insertArrangedSubview(_ view: UIView, aboveArrangedSubview subview: UIView) {
        arrangedSubviews.enumerated().forEach {
            if $0.1 == subview {
                insertArrangedSubview(view, at: $0.0)
            }
        }
    }
}

extension Reactive where Base: UIStackView {
    public var alignment: Binder<UIStackView.Alignment> {
        Binder(base) { stackView, alignment in
            stackView.alignment = alignment
        }
    }
}
