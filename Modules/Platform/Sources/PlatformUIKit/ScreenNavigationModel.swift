// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation

public struct ScreenNavigationModel {
    public let leadingButton: Screen.Style.LeadingButton
    public let trailingButton: Screen.Style.TrailingButton
    public let barStyle: Screen.Style.Bar
    public let titleViewStyle: Screen.Style.TitleView

    public init(
        leadingButton: Screen.Style.LeadingButton,
        trailingButton: Screen.Style.TrailingButton,
        titleViewStyle: Screen.Style.TitleView,
        barStyle: Screen.Style.Bar
    ) {
        self.leadingButton = leadingButton
        self.trailingButton = trailingButton
        self.titleViewStyle = titleViewStyle
        self.barStyle = barStyle
    }
}

extension ScreenNavigationModel {
    public static let noneDark = ScreenNavigationModel(
        leadingButton: .none,
        trailingButton: .none,
        titleViewStyle: .none,
        barStyle: .darkContent()
    )
}

extension ScreenNavigationModel: Equatable {}
