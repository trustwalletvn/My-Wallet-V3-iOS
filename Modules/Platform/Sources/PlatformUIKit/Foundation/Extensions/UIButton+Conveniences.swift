// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxCocoa
import RxSwift

public struct ButtonContent: Equatable {

    public enum Border: Equatable {
        case no
        case yes(width: CGFloat, color: UIColor)
    }

    public static let defaultFont: UIFont = .systemFont(ofSize: 12)
    public static let defaultColor: UIColor = .clear

    public static var empty: ButtonContent {
        ButtonContent()
    }

    let text: String
    let font: UIFont
    let color: UIColor
    let backgroundColor: UIColor?
    let border: Border
    let cornerRadius: CGFloat
    let accessibility: Accessibility

    public init(
        text: String = "",
        font: UIFont = ButtonContent.defaultFont,
        color: UIColor = ButtonContent.defaultColor,
        backgroundColor: UIColor? = nil,
        border: Border = .no,
        cornerRadius: CGFloat = 0,
        accessibility: Accessibility = .none
    ) {
        self.text = text
        self.font = font
        self.color = color
        self.backgroundColor = backgroundColor
        self.border = border
        self.cornerRadius = cornerRadius
        self.accessibility = accessibility
    }

    public static func == (lhs: ButtonContent, rhs: ButtonContent) -> Bool {
        lhs.text == rhs.text
    }

    var isEmpty: Bool {
        text.isEmpty
    }
}

extension UIButton {
    public var content: ButtonContent {
        get {
            var border: ButtonContent.Border = .no
            if layer.borderWidth != 0,
               let cgColor = layer.borderColor
            {
                border = .yes(width: layer.borderWidth, color: UIColor(cgColor: cgColor))
            }
            return ButtonContent(
                text: title(for: .normal) ?? "",
                font: titleLabel?.font ?? ButtonContent.defaultFont,
                color: titleColor(for: .normal) ?? ButtonContent.defaultColor,
                backgroundColor: backgroundColor,
                border: border,
                cornerRadius: layer.cornerRadius,
                accessibility: accessibility
            )
        }
        set {
            setTitle(newValue.text, for: .normal)
            titleLabel?.font = newValue.font
            setTitleColor(newValue.color, for: .normal)
            backgroundColor = newValue.backgroundColor
            accessibility = newValue.accessibility
            if newValue.cornerRadius != layer.cornerRadius {
                layer.cornerRadius = newValue.cornerRadius
                layer.masksToBounds = true
            }
            switch newValue.border {
            case .no:
                layer.borderWidth = 0
                layer.borderColor = nil
            case .yes(width: let width, color: let borderColor):
                layer.borderWidth = width
                layer.borderColor = borderColor.cgColor
            }
        }
    }
}

extension Reactive where Base: UIButton {
    public var content: Binder<ButtonContent> {
        Binder(base) { button, content in
            button.content = content
        }
    }
}
