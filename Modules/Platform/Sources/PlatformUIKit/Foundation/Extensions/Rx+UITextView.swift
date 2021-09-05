// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import RxCocoa
import RxRelay
import RxSwift

extension Reactive where Base: UITextView {
    public var attributedText: Binder<NSAttributedString> {
        Binder(base) { textView, attributedText in
            textView.attributedText = attributedText
        }
    }
}
