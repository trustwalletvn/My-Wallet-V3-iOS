// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources

struct AccountPickerSectionViewModel: SectionModelType {
    typealias Item = AccountPickerCellItem

    var items: [Item]

    var identity: AnyHashable {
        // There's only ever one `AccountPickerSectionViewModel` section
        // so it must be a static string for an identifier.
        "AccountPickerSectionViewModel"
    }

    init(original: AccountPickerSectionViewModel, items: [Item]) {
        self.init(items: items)
    }

    init(items: [Item]) {
        self.items = items
    }
}
