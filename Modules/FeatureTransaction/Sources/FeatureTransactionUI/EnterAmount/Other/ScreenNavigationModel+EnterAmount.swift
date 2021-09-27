// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Localization
import PlatformUIKit

extension ScreenNavigationModel {
    enum EnterAmount {}
}

extension ScreenNavigationModel.EnterAmount {
    public static func navigation(allowsBackButton: Bool) -> ScreenNavigationModel {
        ScreenNavigationModel(
            leadingButton: allowsBackButton ? .back : .none,
            trailingButton: .close,
            titleViewStyle: .none, // will be assigned later through the DisplayBunde of EnterAmountScreen
            barStyle: .darkContent()
        )
    }
}
