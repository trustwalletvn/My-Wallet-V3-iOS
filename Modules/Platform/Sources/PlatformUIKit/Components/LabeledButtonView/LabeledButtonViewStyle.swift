// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public struct LabeledButtonViewStyle {
    let backgroundColor: Color
    let font: UIFont
    let textColor: Color
    let cornerRadius: CGFloat
    let border: ButtonContent.Border

    init(
        backgroundColor: Color,
        font: UIFont,
        textColor: Color,
        cornerRadius: CGFloat = 8,
        border: ButtonContent.Border = .no
    ) {
        self.backgroundColor = backgroundColor
        self.font = font
        self.textColor = textColor
        self.cornerRadius = cornerRadius
        self.border = border
    }
}

extension LabeledButtonViewStyle {
    public static var currency: LabeledButtonViewStyle {
        .init(
            backgroundColor: .lightBlueBackground,
            font: .main(.semibold, 14),
            textColor: .secondary
        )
    }

    public static var currencyOutOfBounds: LabeledButtonViewStyle {
        .init(
            backgroundColor: .lightRedBackground,
            font: .main(.semibold, 14),
            textColor: .negativePrice
        )
    }
}
