// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit

extension ScreenNavigationModel {
    enum TargetSelection {}
}

extension ScreenNavigationModel.TargetSelection {
    public static func navigation(title: String) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: .none,
            trailingButton: .close,
            titleViewStyle: .text(value: title),
            barStyle: .darkContent()
        )
    }
}
