// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import UIKit

public struct SourceTargetSectionHeaderModel: Equatable {
    static let defaultHeight: CGFloat = 20

    private let sectionTitle: String

    var sectionTitleLabel: LabelContent {
        LabelContent(
            text: sectionTitle,
            font: .main(.medium, 14),
            color: .descriptionText
        )
    }

    public init(sectionTitle: String) {
        self.sectionTitle = sectionTitle
    }
}
