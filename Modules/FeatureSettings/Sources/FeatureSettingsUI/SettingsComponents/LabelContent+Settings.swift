// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import Foundation
import PlatformUIKit

extension LabelContent.Value.Presentation.Content.Descriptors {

    /// Returns a descriptor for a settings cell
    static var settings: LabelContent.Value.Presentation.Content.Descriptors {
        .init(
            fontSize: 16,
            accessibility: .id(Accessibility.Identifier.Settings.SettingsCell.titleLabelFormat)
        )
    }
}
