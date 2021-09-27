// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit
import RxDataSources
import ToolKit

struct ActivityItemsSectionViewModel {
    var items: [ActivityCellItem]

    var identity: AnyHashable {
        // There's only ever one `ActivityItemsSectionViewModel` section
        // so it must be a static string for an identifier.
        "ActivityItemsSectionViewModel"
    }
}

extension ActivityItemsSectionViewModel: AnimatableSectionModelType {
    typealias Item = ActivityCellItem

    init(original: ActivityItemsSectionViewModel, items: [ActivityCellItem]) {
        self = original
        self.items = items
    }
}
