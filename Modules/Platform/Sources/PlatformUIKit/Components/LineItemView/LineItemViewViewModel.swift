// Copyright © Blockchain Luxembourg S.A. All rights reserved.

public final class LineItemViewViewModel {
    let title: LabelContent
    let subtitle: LabelContent

    public var identifier: String {
        "\(title.text) \(subtitle.text)"
    }

    public init(
        title: String,
        subtitle: String
    ) {
        self.title = .init(
            text: title,
            font: .main(.medium, 14),
            color: .descriptionText,
            alignment: .left,
            accessibility: .none
        )
        self.subtitle = .init(
            text: subtitle,
            font: .main(.medium, 16),
            color: .titleText,
            alignment: .left,
            accessibility: .none
        )
    }

    public init(
        title: LabelContent,
        subtitle: LabelContent
    ) {
        self.title = title
        self.subtitle = subtitle
    }
}
