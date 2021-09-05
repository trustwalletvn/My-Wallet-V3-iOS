// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

extension UILabel {
    public var content: LabelContent {
        get {
            LabelContent(
                text: text ?? "",
                font: font,
                color: textColor,
                alignment: textAlignment,
                lineSpacing: 1,
                accessibility: accessibility
            )
        }
        set {
            text = newValue.text
            font = newValue.font
            textColor = newValue.color
            let attrString = NSMutableAttributedString(string: newValue.text)
            attrString.add(lineSpacing: newValue.lineSpacing)
            attributedText = attrString
            textAlignment = newValue.alignment
            accessibility = newValue.accessibility.copy(label: newValue.text)
        }
    }
}

extension Reactive where Base: UILabel {
    public var content: Binder<LabelContent> {
        Binder(base) { $0.content = $1 }
    }
}
