// Copyright © Blockchain Luxembourg S.A. All rights reserved.

import PlatformUIKit

enum DashboardItemDisplayAction<ItemViewModel: Equatable>: Equatable {

    /// No statement should be presented
    case hide

    /// Value of statement with text and optional image name
    case show(ItemViewModel)

    /// Returns the view model
    var viewModel: ItemViewModel? {
        switch self {
        case .show(let viewModel):
            return viewModel
        case .hide:
            return nil
        }
    }
}
