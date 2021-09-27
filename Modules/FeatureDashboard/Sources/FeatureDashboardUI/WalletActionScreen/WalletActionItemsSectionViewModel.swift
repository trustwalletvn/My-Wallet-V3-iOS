// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import RxDataSources
import ToolKit

struct WalletActionItemsSectionViewModel {
    var items: [WalletActionCellType]

    var identity: AnyHashable {
        // There's only ever one `WalletActionItemsSectionViewModel` section
        // so it must be a static string for an identifier.
        "WalletActionItemsSectionViewModel"
    }
}

extension WalletActionItemsSectionViewModel {
    static let empty: WalletActionItemsSectionViewModel = .init(items: [])
}

extension WalletActionItemsSectionViewModel: AnimatableSectionModelType {
    typealias Item = WalletActionCellType

    init(original: WalletActionItemsSectionViewModel, items: [WalletActionCellType]) {
        self = original
        self.items = items
    }
}
