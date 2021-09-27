// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources
import ToolKit

struct SettingsSectionViewModel {
    /// The type of the section that dictates the
    /// header title and its position in the screen
    let sectionType: SettingsSectionType

    /// The view models for the cells
    var items: [SettingsCellViewModel]

    /// An identifiable value to support RxDataSources
    var identity: AnyHashable {
        sectionType.rawValue
    }
}

extension SettingsSectionViewModel: AnimatableSectionModelType {
    typealias Item = SettingsCellViewModel

    init(original: SettingsSectionViewModel, items: [SettingsCellViewModel]) {
        self = original
        self.items = items
    }
}
