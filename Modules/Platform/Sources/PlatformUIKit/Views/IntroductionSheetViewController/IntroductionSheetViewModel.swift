// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct IntroductionSheetViewModel {
    let title: String
    let description: String
    let thumbnail: UIImage
    let buttonTitle: String
    let onSelection: () -> Void

    public init(
        title: String,
        description: String,
        buttonTitle: String,
        thumbnail: UIImage,
        onSelection: @escaping () -> Void
    ) {
        self.title = title
        self.description = description
        self.buttonTitle = buttonTitle
        self.thumbnail = thumbnail
        self.onSelection = onSelection
    }
}
