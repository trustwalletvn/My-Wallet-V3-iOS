// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization

public struct AccountPickerHeaderModel {
    public typealias LocalizedString = LocalizationConstants.WalletPicker
    static let defaultHeight: CGFloat = 169

    private let title: String
    private let subtitle: String
    let imageContent: ImageViewContent
    private let tableTitle: String?

    var titleLabel: LabelContent {
        .init(
            text: title,
            font: .main(.semibold, 20),
            color: .titleText
        )
    }

    var subtitleLabel: LabelContent {
        .init(
            text: subtitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    var tableTitleLabel: LabelContent? {
        guard let tableTitle = tableTitle else { return nil }
        return LabelContent(
            text: tableTitle,
            font: .main(.semibold, 12),
            color: .titleText
        )
    }

    public init(
        title: String,
        subtitle: String,
        imageContent: ImageViewContent,
        tableTitle: String? = LocalizedString.selectAWallet
    ) {
        self.title = title
        self.subtitle = subtitle
        self.imageContent = imageContent
        self.tableTitle = tableTitle
    }
}
